require_relative 'model'
require 'time'

module HighDawn
  class FriendshipCollection < Array

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
      result
    end

    def ==(o)
      id==o.id
    end
  end
end
