require 'ap'
require_relative '../lib/models/twitter_user'
require 'rubygems'
require 'logger'
require_relative '../lib/models/user'

module HighDawn

  class Snapshot

    def self.snapshot
      begin
        REDIS
      rescue NameError
        raise "Could not connect to redis instance. Please instanciate 'REDIS' with redis instance. (REDIS is undefined)"
      end

      twitter=TwitterUser.new
      puts "Generating snapshot for #{twitter.client.user.screen_name} (#{twitter.client.user.id})"
      u=User.new twitter.client.user.id

      #check if there are any changes from last snapshot -- if not skip
      a_friends=u.friends.ids
      a_followers=u.followers.ids
      
      b_friends=twitter.friends
      b_followers=twitter.followers

      new_friends=b_friends - a_friends
      new_followers=b_followers - a_followers

      unfriended = a_friends - b_friends
      lost_followers = a_followers - b_followers

      p "new friends: #{new_friends}"
      p "unfriended: #{unfriended}"
      p "new_followers: #{new_followers}"
      p "lost_followers: #{lost_followers}"

      # persist
      new_friends.each do |nf|
        u.add_friend(nf)
      end

      new_followers.each do |nf|
        u.add_follower(nf)
      end

      unfriended.each do |uf|
        u.remove_friend(uf)
      end

      lost_followers.each do |lf|
        u.remove_follower(lf)
      end

      p u.save
      
      self.cache_usernames(new_friends + new_followers)
    end

    def self.cache_usernames(ids)
      #cache user names
      twitter=TwitterUser.new
      screen_names=[]
      
      ids.each_slice(99).to_a.each do |arr|
        _screen_names=twitter.client.friendships(arr).map{|user| [user.screen_name, user.id]}
        
        _screen_names.each do |screen_name|
          puts "tuid:#{screen_name[1]}=#{screen_name[0]}"
          REDIS.pipelined do
            REDIS.set("tuid:#{screen_name[1]}", screen_name[0])
          end
        end
        screen_names.concat _screen_names
      end
      screen_names
    end

  end #end class

end#module
