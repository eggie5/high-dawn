require './models/model'
require 'time'

class Timeline < Model
  attr_reader :length
  def initialize()

    @length=0
    @hash={}
  end

  def add(time, id1, action, id2)
    ts=time.strftime("%Y.%m.%d")
    struct={event: action,
      follower: id1,
    followee: id2}

    @hash[ts]=[] if @hash[ts].nil?

    @hash[ts].push struct

    @length+=1
  end

  def get(at)
    collection=[]
    @hash.each do |key, value|
      if(Time.parse(key)<=at)
        value.each do |val|
          if(val[:event]==:follow)
            collection.push val[:followee]
          elsif(val[:event]==:unfollow)
            collection.delete val[:followee]
          end
          
        end
      end
    end
    collection
  end
end

