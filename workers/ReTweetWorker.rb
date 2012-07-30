require 'twitter'

class ReTweetWorker
  @queue = :retweet_queue

  def self.perform(tweet_obj)
    uid=tweet_obj.uid #twitter uid of high-dawn user
    retweet=Twitter.retweet(tweet_obj.id)
    
    #everytime a retweet is sent, save a record of it
    
    REDIS.set "users:#{uid}:retweets:#{tweet_obj.id}:json", JSON.parse(retweet)
  end
end
