require 'redis'
require 'time'

class Model

  #THIS IS ALL TEMP UNTIL PERSISTANCE LOGIC ADDED
  def initialize()
    @hash={}
    @r=Redis.new
  end
  #THIS IS ALL TEMP UNTIL PERSISTANCE LOGIC ADDED


  def save
    raise "blank id" if nil?
    @hash.each do |timestamp, bucket|
      bucket.each do |node|
        event=node[:event]
        follower=node[:follower]
        followee=node[:followee]
        key="users:#{id}:timestamp:#{timestamp.to_i}"
        #puts "saving #{key}"
        obj=node
        @r.sadd key, obj

        #add this to the list so I can find this key for lookup later
        @r.zadd "users:#{id}:timestamps", 0, timestamp.to_i
      end
    end
  end

  def self.find(id)
    u=User.new
    u.id=id
    u
  end

  def read(from=3.years.ago, to=Time.now, user_id, filter) #filter = :friends | :followers

    zkey="users:#{user_id}:timestamps"
    all_ts=@r.zrange(zkey, 0, -1).collect(&:to_i)
    timestamps=get_range(all_ts, from.to_i, to.to_i)

    hash=build_hash_from_redis(timestamps, user_id)

    #ap @hash


    collection=FriendshipCollection.new

    hash.each do |timestamp, bucket|
      if(from <= timestamp && timestamp <= to)
        bucket.each do |node|
          event=node[:event]
          follower=node[:follower]
          followee=node[:followee]

          f=Friendship.new
          f.timestamp=timestamp

          if(filter==:friends)
            if(follower==user_id)
              f.id=followee
              if(event==:follow)
                collection.push f
              elsif(event==:unfollow)
                collection.delete f
              end
            end
          elsif(filter==:followers)
            if(followee==user_id)
              f.id=follower
              if(event==:follow)
                collection.push f
              elsif(event==:unfollow)
                collection.delete f
              end
            end
          end


        end
      end
    end
    collection
    # collection=FriendshipCollection.new
    #
    #     key="users:#{user_id}:timestamp:#{from.to_i}"
    #     puts "read key=#{key}"
    #     resp=@r.smembers(key)
    #     arr=deseralize_redis(resp)
    #
    #     arr.each do |friendship_hash|
    #       event=friendship_hash[:event]
    #       follower=friendship_hash[:follower]
    #       followee=friendship_hash[:followee]
    #       f=Friendship.new
    #       f.timestamp=from
    #
    #       case filter
    #       when :friends
    #         f.id=followee
    #         if(event==:follow)
    #           collection.push f
    #         elsif(event==:unfollow)
    #           collection.delete f
    #         end
    #       when :followers
    #         f.id=follower
    #         if(event==:follow)
    #           collection.push f
    #         elsif(event==:unfollow)
    #           collection.delete f
    #         end
    #       end
    #     end
    #     collection
  end

  def build_hash_from_redis(timestamps, user_id)
    hash={}
    timestamps.each do |ts|
      key="users:#{user_id}:timestamp:#{ts}"
      resp=@r.smembers(key)
      hashes=deseralize_redis(resp)

      time=Time.at(ts)
      hash[time]=[] if hash[time].nil?
      hashes.each do |struct|
        hash[time].push struct
      end
    end
    hash
  end
  
  private
  def deseralize_redis(r)
    r.collect{|str| eval str}
  end

  def get_range(arry, s, e)
    a=[]
    arry.each do |i|
      a.push i if(s <= i && i <= e)
    end
    a
  end



end
