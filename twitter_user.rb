require 'twitter'
require 'ap'
require 'yaml'

class TwitterUser
  attr_reader :client, :uid
  def initialize(options={})
    
    @client = options[:twitter_config]

    s= Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"
    puts s

    @uid = options[:uid] || Twitter.user(options[:handle]).id
  end

  def friends
    @friends ||= @client.friend_ids(uid).ids
  end

  def followers
    @followers ||= @client.follower_ids(uid).ids
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


