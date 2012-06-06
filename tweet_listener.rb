#this app(producer) takes tweets from selected users and puts them in a queue
#to be consumed by another component (consumer)
#this app should be restarted every T periond or refresh non_bros list of ids

require 'tweetstream'
require 'logger'
require 'resque'
require 'redis'
require 'ap'
require 'yaml'
require './workers/ReTweetWorker'
require 'json'

ENV["REDISTOGO_URL"] = 'redis://redistogo:f793febde5cb91ab39a7e1223be904bc@scat.redistogo.com:9198'
uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis = REDIS

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require './webapp/app/models/user.rb'

dbconfig = YAML::load(File.open('./webapp/config/database.yml'))
ap dbconfig
ActiveRecord::Base.establish_connection(dbconfig['development'])
ActiveRecord::Base.logger = Logger.new(STDERR)


# Start the log over whenever the log exceeds 100 megabytes in size.
$LOG = Logger.new('tweet_listener.log', 0, 100 * 1024 * 1024)
def self.log(msg)
  p msg
  $LOG.debug("#{msg} \n")
end

#collect list of all non_bros for every user
ids=[]
User.all .each do |user|
  user_ids=user.snapshot({at: :last, for: :non_bros}).map{|id|id.to_i}
  ids.concat user_ids
end

p ids

raise "no dick cheney" unless ids.include? 539428398



yaml = YAML.load_file("oauth.yaml")
TweetStream.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = yaml["oauth_token"]
  config.oauth_token_secret = yaml["oauth_token_secret"]
  config.auth_method = :oauth
end

#539428398 dick cheney

p "listening..."
TweetStream::Client.new.follow(ids) do |status|
  #puts "#{status.user.name} (#{status.user.id}): #{status.id}"
  puts "."
  tuid=status.user.id
  obj={id: status.id, uid: status.user.id, text: status.text }
  
  #cache id -> uname for O(1) lookup
  REDIS.set("tuid:#{tuid}", status.user.screen_name)
  
  #return if status.text.contains("RT") #skip a retweet

  #get a list of people following this tweet owner
  #twitter uid -> user id lookup
  uid_list=REDIS.smembers("tuid:#{tuid}:followers")||[]
  uid_list.each do |uid|
    queue_key="user:#{uid}:pending_tweet_list"
    REDIS.rpush queue_key, obj.to_json
    puts "pushed #{status.id} to #{queue_key}"
  end

end
