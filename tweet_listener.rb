require 'tweetstream'
require 'logger'

# Start the log over whenever the log exceeds 100 megabytes in size. 
$LOG = Logger.new('tweet_listener.log', 0, 100 * 1024 * 1024)

#get list of targets from database
users = redis.get "non_bros"

def self.log(msg)
  $LOG.debug(msg)
end


#pass ids as args to twitter streaming api
# Use 'follow' to follow a group of user ids (integers, not screen names)
TweetStream::Client.new.follow(14252, 53235) do |status|
  
  #when tweet comes, pass it to rules engine
  job_queue.push status
  self.log(status.inspect)
end