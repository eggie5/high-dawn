require './models/model'
require 'time'

class FriendshipCollection < Array
  
  def set(arr)
    replace arr
  end
  
  def ids
    self.collect{|friendship|friendship.id}
  end
  
  
  
end

class Friendship
  attr_accessor :timestamp, :id

  def initialize()
  end
  
  def tweets=(arr)
  end
  
  def tweets
    #do DB lookup for tweets?
    []
  end

  def eql?(o)
    self==(o)
  end

  def hash
    prime = 31;
    result = 1;
    result = prime * result + ((id == nil) ? 0 : id.hash);
    #result = prime * result + ((timestamp == nil) ? 0 : timestamp.to_s.hash);
    result
  end

  def ==(o)
    id==o.id # &&
    #     timestamp.year==o.timestamp.year &&
    #     timestamp.month==o.timestamp.month &&
    #     timestamp.day==o.timestamp.day
  end
end

class Timeline < Model
  attr_reader :length
  def initialize()
    @length=0
    @hash={}
  end

  #time, id1, action, id2
  def add(options={})
    ts=options[:time].strftime("%Y.%m.%d")
    struct={  event: options[:action],
      follower: options[:follower],
    followee: options[:followee] }

    @hash[ts]=[] if @hash[ts].nil?

    @hash[ts].push struct

    @length+=1
  end

  def get(at, user_id)
    collection=FriendshipCollection.new
    @hash.each do |key, value|
      if(Time.parse(key)<=at)
        value.each do |val|
          if(val[:event]==:follow)
            id= (val[:followee]== user_id )? val[:follower] : val[:followee]
            f=Friendship.new
            f.timestamp=Time.parse(key)
            f.id=id
            collection.push f
          elsif(val[:event]==:unfollow)
            id= (val[:followee]== user_id )? val[:follower] : val[:followee]
            f=Friendship.new
            f.timestamp=Time.parse(key)
            f.id=id
            collection.delete f
          end

        end
      end
    end
    collection
  end
end
