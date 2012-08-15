require "rubygems"
require "bundler/setup"

# require your gems as usual
require "tweetstream"
require 'high-dawn'
require 'resque'
require 'active_record'

class User < ActiveRecord::Base
end

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
      #collect list of all non_bros for every user
      #TODO: convert this AR call to REST API call
      ids=[]
      ::User.all.each do |user|
        user=HighDawn::User.new user.uid.to_i
        user_ids=user.non_bros.ids
        ids.concat user_ids
      end

      ids
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
        #p obj={id: tweet.id, uid: tweet.user.id, text: tweet.text }

        #cache id -> uname for O(1) lookup
        HighDawn::TweetModel.cache_id non_bro.id, tweet.user.screen_name

        next if htweet.retweet? #dont care about retweets
        puts "."

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
