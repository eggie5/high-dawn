require './models/model'
require './models/timeline'
require 'time'


class User < Model
  attr_accessor :id, :email, :tuid
  def initialize()
    @friends=Timeline.new()
    @followers=Timeline.new()
  end

  def add_friend(ts=Time.now, id)
    @friends.add(time: ts, follower: self.id, action: :follow, followee: id)
  end

  def remove_friend(ts=Time.now, id)
     @friends.add(time: ts, follower: self.id, action: :unfollow, followee: id)
  end

  def add_follower(ts=Time.now, id)
    @followers.add(time: ts, follower: id, action: :follow, followee: self.id)
  end

  def remove_follower(ts=Time.now, id)
    @followers.add(time: ts, follower: id, action: :unfollow, followee: self.id)
  end



  def followers=(followers)
    @followers=followers
  end

  def bros(options={})
    at=options[:at] || Time.now
    friends=friends(at: at) 
    followers=followers(at: at)
    (friends & followers)
  end

  def non_bros(options={})
    at=options[:at] || Time.now
    (friends(at: at) - bros(at: at))
  end

  def friends(options={})
    at=options[:at]
    if at
      ts=at.strftime("%Y.%m.%d")

      @friends.get Time.parse(ts), self.id
    else
      @friends #return all
    end
  end
  
  def followers(options={})
    at=options[:at]
    if at
      ts=at.strftime("%Y.%m.%d")

      @followers.get Time.parse(ts), self.id
    else
      @followers #return all
    end
  end

  def friends=(friends)
    @friends=friends
  end
end
