require "rubygems"
require "bundler/setup"
require 'twitter'
require 'redis'
require 'high-dawn'

#load creds from yaml
yaml = YAML.load_file("./oauth.yaml")
user=yaml["fashionfever5"]

Twitter.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = user["oauth_token"]
  config.oauth_token_secret = user["oauth_token_secret"]
end


REDIS=Redis.new(db:5)
REDIS.flushdb

puts "Generating snapshot for #{Twitter.user.screen_name} (#{Twitter.user.id})"

diff= HighDawn::Snapshot.snapshot

ap diff

new_ids=(diff[:new_friends] + diff[:new_followers]).uniq
p "#{new_ids.length} diffs!"

p HighDawn::TweetModel::cache_usernames new_ids


