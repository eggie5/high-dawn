require 'redis'

class Model

  #THIS IS ALL TEMP UNTIL PERSISTANCE LOGIC ADDED
  attr_reader :length
  def initialize()
    @length=0
    @hash={}
    @r=Redis.new
  end
  #THIS IS ALL TEMP UNTIL PERSISTANCE LOGIC ADDED



  #save shouldn't use read....
  #this does :(
  def save
    raise "blank id" if id.blank?
    @hash.each do |timestamp, bucket|
      bucket.each do |node|
        event=node[:event]
        follower=node[:follower]
        followee=node[:followee]
        key="users:#{id}:timestamp:#{timestamp.to_i}"
        puts "saving #{key}"
        obj=node
        @r.sadd key, obj
      end
    end
  end

  def self.find(id)
    u=User.new
    u.id=id
    u
  end

  def read(from, to, user_id, filter) #filter = :friends | :followers
    collection=FriendshipCollection.new

    @hash.each do |timestamp, bucket|
      if(timestamp<=from)
        bucket.each do |node|
          event=node[:event]
          follower=node[:follower]
          followee=node[:followee]

          f=Friendship.new
          f.timestamp=timestamp

          if(filter==:friends)
            if(follower==user_id)
              #this is a freind node, update collection
              f.id=followee
              if(event==:follow)
                collection.push f
              elsif(event==:unfollow)
                collection.delete f
              end
            end
          elsif(filter==:followers)
            if(followee==user_id)
              #this is a follower node, update collection
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

  private
  def deseralize_redis(r)
    r.collect{|str| eval str}
  end

end

# users:XXXX:followers:timestamp:2012.07.23:event = follow
# users:XXXX:followers:timestamp:2012.07.23:follower = 4
# users:XXXX:followers:timestamp:2012.07.23:followee = 1

# users:XXXX:friends:timestamp:2012.07.19:event = follow
# users:XXXX:friends:timestamp:2012.07.19:follower = 1
# users:XXXX:friends:timestamp:2012.07.19:followee = 2

# users:XXXX:friends:timestamp:2012.07.23:event = follow
# users:XXXX:friends:timestamp:2012.07.23:follower = 1
# users:XXXX:friends:timestamp:2012.07.23:follower = 23
# users:XXXX:friends:timestamp:2012.07.23:event = follow
# users:XXXX:friends:timestamp:2012.07.23:follower = 1
# users:XXXX:friends:timestamp:2012.07.23:follower = 23

#
# #<User:0x7fe08dd169b8
#     attr_accessor :followers = #<Timeline:0x7fe08dd16940
#         attr_reader :hash = {
#             "2012.07.23" => [
#                 [0] {
#                        :event => :follow,
#                     :follower => 4,
#                     :followee => 1
#                 }
#             ]
#         },
#         attr_reader :length = 1
#     >,
#     attr_accessor :friends = #<Timeline:0x7fe08dd16990
#         attr_reader :hash = {
#             "2012.07.19" => [
#                 [0] {
#                        :event => :follow,
#                     :follower => 1,
#                     :followee => 2
#                 }
#             ],
#             "2012.07.22" => [
#                 [0] {
#                        :event => :follow,
#                     :follower => 1,
#                     :followee => 3
#                 }
#             ],
#             "2012.07.23" => [
#                 [0] {
#                        :event => :follow,
#                     :follower => 1,
#                     :followee => 23
#                 },
#                 [1] {
#                        :event => :follow,
#                     :follower => 1,
#                     :followee => 33
#                 }
#             ],
#             "2012.07.24" => [
#                 [0] {
#                        :event => :unfollow,
#                     :follower => 1,
#                     :followee => 2
#                 }
#             ]
#         },
#         attr_reader :length = 5
#     >,
#     attr_accessor :id = 1
