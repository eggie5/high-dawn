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

#ENV["OPENREDIS_URL"] = 'redis://:JbUzPW0aS1hVg5jPX3n40OzPjEalMQOTSiOeT6MRKgViNolrJuJKmemmhN56CiCt@50.19.218.147:10097/0'
ENV["OPENREDIS_URL"]="redis://localhost:6379/0"
uri = URI.parse(ENV["OPENREDIS_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

dbconfig = YAML::load(File.open('./database.yml'))
# ap dbconfig
ActiveRecord::Base.establish_connection(dbconfig['development'])
ActiveRecord::Base.logger = Logger.new(STDERR)

p user_ids = HighDawn::Listener.ids

listener = HighDawn::Listener.new
listener.listen_to user_ids