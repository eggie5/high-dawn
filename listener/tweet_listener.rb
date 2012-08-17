require "rubygems"
require "bundler/setup"

# require your gems as usual
require "tweetstream"
require 'high-dawn'
require 'resque'
require "net/http"
require "uri"

module HighDawn
  class Listener
    def initialize()
      # Start the log over whenever the log exceeds 100 megabytes in size.
      $LOG = Logger.new('tweet_listener.log', 0, 100 * 1024 * 1024)
    end

    def self.log(msg)
      p msg
      $LOG.debug("#{msg} \n")
    end

    def self.ids
      if(ENV["HD_ENV"]=="production")
        url="http://high-dawn-7765.herokuapp.com/uids.json"
      else
        url="http://localhost:5200/uids.json"
      end
      
      #collect list of all non_bros for every user
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      _uids=JSON.parse response.body
      uids=[]
      _uids.each do |uid|
        user=HighDawn::User.new uid.to_i
        user_ids=user.non_bros.ids
        uids.concat user_ids
      end

      uids
    end


    def listen_to(non_bros)
      p "listening..."
      client=TweetStream::Client.new

      client.on_limit do |skip_count|
        p "rate limit. skip_count=#{skip_count}"
      end

      client.on_error do |message|
        p "error: #{message}"
      end

      client.follow(non_bros) do |tweet|
        htweet = HighDawn::Tweet.create text: tweet.text, tuid: tweet.user.id
        non_bro = HighDawn::NonBro.new(tweet.user.id)


        #cache id -> uname for O(1) lookup
        HighDawn::TweetModel.cache_id non_bro.id, tweet.user.screen_name

        next if htweet.retweet? #dont care about retweets
        p obj={id: tweet.id, uid: tweet.user.id, text: tweet.text }
        # puts "."

        #get a list of users following this tweet's owner
        p followers = non_bro.followers
        followers.each do |id|
          u=HighDawn::User.new id
          u.queue << htweet
          u.save
        end
      end
    end

  end#cl
end#mod
