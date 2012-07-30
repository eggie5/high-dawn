require 'twitter'
require 'ap'
require 'yaml'
require '../twitter_user'
require 'rubygems'
require 'active_record'
require 'logger'
require '../models/user'


#load creds from yaml
yaml = YAML.load_file("../oauth.yaml")
twitter_config = Twitter.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = yaml["oauth_token"]
  config.oauth_token_secret = yaml["oauth_token_secret"]
end
u=User.new;u.id=1
user_handle="eggie5"
twitter=TwitterUser.new({handle: user_handle, twitter_config: twitter_config})
uid=user_id=twitter.uid

#check if there are any changes from last snapshot -- if not skip
a_friends=u.friends
a_followers=u.followers

p a_friends.class
p a_followers.class

b_friends=twitter.friends
b_followers=twitter.followers

new_friends=b_friends - a_friends
new_followers=b_followers - a_followers

unfriended = a_friends - b_friends
lost_followers = a_followers - b_followers

p "new friends: #{new_friends}"
p "unfriended: #{unfriended}"
p "new_followers: #{new_followers}"
p "lost_followers: #{lost_followers}"

#persist
new_friends.each do |nf|
  u.add_friend(nf)
end

new_followers.each do |nf|
  u.add_follower(nf)
end

unfriended.each do |uf|
  u.remove_friend(uf)
end

lost_followers.each do |lf|
  u.remove_follower(lf)
end

ap u

u.save


