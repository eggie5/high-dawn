require 'twitter'

module HighDawn
  class TwitterUser
    attr_reader :client
    def initialize(options={})

      begin
        Twitter.user
      rescue
        raise "could not find twitter instance"
      end

      @client = Twitter

      s= Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"
      puts s
    end

    def friends
      @friends ||= @client.friend_ids(@client.user.id).ids
    end

    def followers
      @followers ||= @client.follower_ids(@client.user.id).ids
    end

    def bros
      @bros ||= (@friends & @followers)
    end

    def non_bros
      @non_bros ||= (@friends - @bros)
    end

    def invalidate_cache
      @friends = @followers = @bros = @non_bros = nil
    end

  end
end
