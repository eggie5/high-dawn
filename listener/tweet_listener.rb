require "rubygems"
require "bundler/setup"

# require your gems as usual
require "tweetstream"
require 'high-dawn'
require 'resque'
require "net/http"
require "uri"

# Start the log over whenever the log exceeds 100 megabytes in size.
$LOG = Logger.new(File.dirname(__FILE__)+"/tweet_listener.log", 0, 100 * 1024 * 1024)
$LOG.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime}: #{msg}\n"
end

module HighDawn
  class Listener
    def initialize()
    end

    def self.log(msg)
      p msg
      $LOG.info(msg)
    end

    def self.ids
      if(ENV["HD_ENV"]=="production")
        url="http://high-dawn-7765.herokuapp.com/uids.json"
        self.log "Running in production! #{url}"
      else
        url="http://localhost:5200/uids.json"
        self.log "Running in local #{url}"
      end

      #collect list of all non_bros for every user
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      _uids=JSON.parse response.body
      uids=[]
      _uids.each do |uid|
        user=HighDawn::User.new uid.to_i
        user_ids=user.watch_list
        uids.concat user_ids
      end
      self.log "found #{uids.length} uids to monitor"
      uids
    end

    def listen_to(non_bros)
      Listener.log "listening..."
      client=TweetStream::Client.new

      client.on_limit do |skip_count|
        Listener.log "rate limit. skip_count=#{skip_count}"
      end

      client.on_error do |message|
        Listener.log "error: #{message}"
      end

      client.follow(non_bros) do |tweet|
        htweet = HighDawn::Tweet.create text: tweet.text, tuid: tweet.user.id
        next if htweet.retweet? #dont care about retweets
        obj={uid: tweet.user.id, text: tweet.text }
        Listener.log obj

        #get a list of users following this tweet's owner
        non_bro = HighDawn::NonBro.new(tweet.user.id)
        followers = non_bro.followers
        next if followers.empty? #skip if no followers
        
        Listener.log "caching id #{tweet.user.screen_name} and saving his tweet to subscribers: #{followers}"        
        HighDawn::TweetModel.cache_id(non_bro.id, tweet.user.screen_name)

        followers.each do |id|
          u=HighDawn::User.new id
          u.queue << htweet
          u.save
        end
      end
    end

  end#cl
end#mod
