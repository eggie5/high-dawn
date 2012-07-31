require './spec/spec_helper'
require 'redis'
require 'ap'

describe Model do
  it "should propery deseralize data structure from redis keys" do
    #seed redis
    u=User.new;u.id=1
    t=100.days.ago
    u.add_friend(t,3)
    u.save

    m=Model.new
    resp = m.read(100.days.ago, Time.now, u.id, :friends)
    # resp.class.should eq FriendshipColllection
  end

  it "should property seralize data structure to redis keys" do
    #build DS in memory
    u=User.new;u.id=1
    t=Time.now
    u.add_friend(t,3)
    u.save

    r=Redis.new
    membs = r.smembers "users:#{u.id}:timestamp:#{t.to_i}"
    f=membs.collect{|str| eval str }[0]
    f[:event].should eq :follow
    f[:follower].should eq u.id
    f[:followee].should eq 3


    u.add_follower(t,5)
    u.save

    a=r.smembers("users:#{u.id}:timestamp:#{t.to_i}").collect{|str| eval str}

    a[0][:event].should eq :follow
    a[0][:follower].should eq 5
    a[0][:followee].should eq u.id

    a[1][:event].should eq :follow
    a[1][:follower].should eq u.id
    a[1][:followee].should eq 3



  end


  describe Friendship do
    it "should work w/ set logic" do

      f1=Friendship.new
      f1.id=1
      f1.timestamp=10.days.ago

      f2=Friendship.new
      f2.id=1
      ts=5.days.ago
      f2.timestamp=ts

      f3=Friendship.new
      f3.id=2
      f3.timestamp=3.days.ago

      #this says i was friends with f1 at sample a
      #and I was frinds w/ f1 & f2 on sample b
      #now find the intersection. it should return f2
      a=[f1]
      b=[f2, f3]

      inter = b & a

      inter.length.should eq 1
      inter[0].id.should eq f2.id
      inter[0].timestamp.should eq f2.timestamp

    end


  end

end
