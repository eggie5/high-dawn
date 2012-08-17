require "rubygems"
require "bundler/setup"

# require your gems as usual
require "yaml"
require "tweetstream"
require "high-dawn"
require_relative "tweet_listener"

yaml = YAML.load_file("oauth.yaml")
user=yaml["eggie5"]
TweetStream.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = user["oauth_token"]
  config.oauth_token_secret = user["oauth_token_secret"]
  config.auth_method = :oauth
end

if(ENV["HD_ENV"]=="production")
  p "production env!!!"
  ENV["REDIS_URL"]="redis://:JbUzPW0aS1hVg5jPX3n40OzPjEalMQOTSiOeT6MRKgViNolrJuJKmemmhN56CiCt@50.19.218.147:10097/0"
else
  ENV["REDIS_URL"]="redis://localhost:6379/0"
end

uri = URI.parse(ENV["REDIS_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

dbconfig = YAML::load(File.open('./database.yml'))
# ap dbconfig

user_ids = HighDawn::Listener.ids

listener = HighDawn::Listener.new
listener.listen_to user_ids