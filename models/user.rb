require_relative 'model'
require_relative 'timeline'

class User < Model
  attr_accessor :id, :email, :tuid
  def initialize()
    super
  end

  def add_friend(ts=Time.now, id)
    add(time: ts, follower: self.id, action: :follow, followee: id)
  end

  def remove_friend(ts=Time.now, id)
    add(time: ts, follower: self.id, action: :unfollow, followee: id)
  end

  def add_follower(ts=Time.now, id)
    add(time: ts, follower: id, action: :follow, followee: self.id)
  end

  def remove_follower(ts=Time.now, id)
     add(time: ts, follower: id, action: :unfollow, followee: self.id)
  end
  
  #addes node to in-memory hash
  def add(options={})
    ts=options[:time]
    struct={  event: options[:action],
      follower: options[:follower],
    followee: options[:followee] }

    @hash[ts]=[] if @hash[ts].nil?

    @hash[ts].push struct

    @length+=1
  end


  def followers=(followers)
    @followers=followers
  end

  def bros(options={})
    at=options[:from] || Time.now
    friends=friends(from: at)
    followers=followers(from: at)
    inter=(followers & friends)
    f=FriendshipCollection.new()
    f.replace(inter)
    f
  end

  def non_bros(options={})
    at=options[:from] || Time.now
    (friends(from: at) - bros(from: at))
  end

  def friends(options={})
    from=options[:from] || Time.now
    to=options[:to] || Time.now

    read(from, to, self.id, :friends)
  end
  
  def friends=(friends)
    @friends=friends
  end

  def followers(options={})
    from=options[:from] || Time.now
    to=options[:to] || Time.now

    read(from, to, self.id, :followers)
  end


end
