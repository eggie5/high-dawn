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



  #put persistance logic here
  #redis, postgres, mongo???
  def save
    friends.each do |friend|
      ts=friend.timestamp.to_i
      fid=friend.id
      p base="users:#{id}:timestamp:#{ts}"

      event_key=base+"event"
      follower_key=base+"follower"
      followee_key=base+"followee"
      
      obj={event: :follow, follower: id, followee: fid}
      p @r.sadd base, obj
      puts ""
    end
    followers.each do |friend|
      ts=friend.timestamp.to_i
      fid=friend.id
      p base="users:#{id}:timestamp:#{ts}"

      event_key=base+"event"
      follower_key=base+"follower"
      followee_key=base+"followee"
      
      obj={event: :follow, follower: fid, followee: id}
      p @r.sadd base, obj
      puts ""
    end
  end

  def self.find(id)
    u=User.new
    u.id=id
    u
  end

  def read(from, to, user_id, filter) #filter = :friends | :followers
    #query redis aand build the correct data structure
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
