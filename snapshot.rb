require 'twitter'
require 'ap'
require 'yaml'
require 'redis'
require './twitter_user'

#load creds from yaml
yaml = YAML.load_file("oauth.yaml")
twitter_config = Twitter.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = yaml["oauth_token"]
  config.oauth_token_secret = yaml["oauth_token_secret"]
end

user_handle="eggie5"
user=TwitterUser.new({handle: user_handle, twitter_config: twitter_config})
user_id=user.uid

#get people youre following
following=user.friends
followers=user.followers

mutual_friends=bros=user.bros
non_bros=user.non_bros
i_need_to_follow=followers-mutual_friends

p "following: #{following.length}"
p "followers: #{followers.length}"
p "bros: #{bros.length}"
p "non-bros: #{non_bros.length}"
p "im not following back: #{i_need_to_follow.length}"


#
#REDIS = Redis.new
ENV["REDISTOGO_URL"] = 'redis://redistogo:f793febde5cb91ab39a7e1223be904bc@scat.redistogo.com:9198'
uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

timestamp=Time.now.to_i#Time.now.strftime("%Y-%m-%d--%H:%M")
following_key ="uid:#{user_id}:following_ids:#{timestamp}"
followers_key="uid:#{user_id}:follower_ids:#{timestamp}"
unreciprocated_friends_key="uid:#{user_id}:unreciprocated_friends_ids:#{timestamp}"
reciprocated_friends_key="uid:#{user_id}:reciprocated_friends_ids:#{timestamp}"
p following_key ##eggie5_urf_at_2012-05-27--22:40

REDIS.pipelined do
  REDIS.sadd(following_key, following)
  REDIS.sadd(followers_key, followers)
  REDIS.sadd(unreciprocated_friends_key, non_bros)
  REDIS.sadd(reciprocated_friends_key, bros)

  REDIS.rpush "uid:#{user_id}:following_snapshots", following_key
  REDIS.rpush "uid:#{user_id}:followers_snapshots", followers_key
  REDIS.rpush "uid:#{user_id}:unreciprocated_friends_snapshots", unreciprocated_friends_key
  REDIS.rpush "uid:#{user_id}:reciprocated_friends_snapshots", reciprocated_friends_key
end

#cache user names
[following, followers].each do |tuids|
  screen_names=[]
  tuids.each_slice(99).to_a.each do |arr|
    _screen_names=Twitter.friendships(arr).map{|user| [user.screen_name, user.id]}
    _screen_names.each do |screen_name|
      puts "tuid:#{screen_name[1]}"
      REDIS.pipelined do
        REDIS.set("tuid:#{screen_name[1]}", screen_name[0])
      end
    end
    screen_names.concat _screen_names
  end
end
