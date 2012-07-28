require './models/model'
require './models/timeline'
require 'time'


class User < Model
  attr_accessor :id, :email, :tuid
  def initialize()
    @friends=Timeline.new
    @followers=Timeline.new
  end

  def followers(options={})
    at=options[:at]
    if at
      ts=at.strftime("%Y.%m.%d")

      @followers.get Time.parse(ts)
    else
      @followers #return all
    end
  end

  def followers=(followers)
    @followers=followers
  end

  def bros(options={})
    at=options[:at] || Time.now
    (friends(at: at) & followers(at: at))
  end

  def non_bros(options={})
    at=options[:at] || Time.now
    (friends(at: at) - bros(at: at))
  end

  def friends(options={})
    at=options[:at]
    if at
      ts=at.strftime("%Y.%m.%d")

      @friends.get Time.parse(ts)
    else
      @friends #return all
    end
  end

  def friends=(friends)
    @friends=friends
  end
end
