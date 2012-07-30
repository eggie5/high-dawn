require './spec/spec_helper'

describe Model do
  it "should propery deseralize data structure from redis keys" do
    #seed redis
    #Redis.put "users:1:followers:timestamp:1343636608:event"
    
    m=Model.new
    timeline = m.read(1.week.ago, Time.now, 1, :friends)
  end
  
  it "should property seralize data structure to redis keys" do
    #build DS in memory
    u=User.new;u.id=1
    u.add_friend(3)
    u.add_follower(1)
    
    #u.save
  end
  
  describe Model, "#add" do
    it "adds even to timeline" do
      timeline=Model.new

      today=Time.now
      timeline.add(time: today, followee: 3, action: :follow, follower: 4)
      timeline.add(time: today, followee: 3, action: :unfollowed, follower: 5);

      timeline.length.should eq(2)

    end
  end

  describe Model, "#get" do
    it "should get a collection of users at a certain point in time" do
      t=Model.new
      t.add(time: 3.days.ago, followee: 2, action: :follow, follower: 1)
      t.add(time: 2.days.ago, followee: 3, action: :follow, follower: 1)
      t.add(time: 1.days.ago, followee: 4, action: :follow, follower: 1)
      t.add(time: Time.now,   followee: 5, action: :follow, follower: 1)
      ########### end setup

      friends=t.read(Time.now, nil, 1, :friends)
      friends.length.should eq 4
      friend=friends[0]
      friend.timestamp.day.should eq 3.days.ago.day
      friend.id.should eq 2
    end
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
