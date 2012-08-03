require "rubygems"
require "bundler/setup"
require 'twitter'
require 'redis'
require 'high-dawn'

#load creds from yaml
yaml = YAML.load_file("./oauth.yaml")
Twitter.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = yaml["oauth_token"]
  config.oauth_token_secret = yaml["oauth_token_secret"]
end

REDIS=Redis.new


HighDawn::Snapshot.snapshot