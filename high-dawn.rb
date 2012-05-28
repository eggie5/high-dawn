require 'twitter'
require 'ap'
require 'yaml'
require 'redis'

s= Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"
puts s

#load creds from yaml
yaml = YAML.load_file("oauth.yaml")
Twitter.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = yaml["oauth_token"]
  config.oauth_token_secret = yaml["oauth_token_secret"]
end

user_handle="eggie5"
user_id = Twitter.user(user_handle).id

#get people youre following
following=Twitter.friend_ids(user_id).ids
followers=Twitter.follower_ids(user_id).ids

mutual_friends=bros=following & followers
non_bros=following-mutual_friends
i_need_to_follow=followers-mutual_friends

p "following: #{following.length}"
p "followers: #{followers.length}"
p "bros: #{bros.length}"
p "non-bros: #{non_bros.length}"
p "im not following back: #{i_need_to_follow.length}"


#
REDIS = Redis.new
timestamp=Time.now.strftime("%Y-%m-%d--%H:%M")
following_key ="#{user_handle}_following_at_#{timestamp}" #reciprocated_friends
followers_key="#{user_handle}_followers_at_#{timestamp}" #unreciprocated_friends
p following_key ##eggie5_urf_at_2012-05-27--22:40

following.each{|id| REDIS.sadd(following_key, id)}
followers.each{|id| REDIS.sadd(followers_key, id)}

REDIS.rpush "#{user_handle}_following_snapshots", following_key
REDIS.rpush "#{user_handle}_followers_snapshots", followers_key
