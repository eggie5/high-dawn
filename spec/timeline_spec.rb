require './spec/spec_helper'


describe Timeline, "#add" do
  it "adds even to timeline" do
    timeline=Timeline.new

    today=Time.now
    timeline.add(time: today, followee: 3, action: :follow, follower: 4)
    timeline.add(time: today, followee: 3, action: :unfollowed, follower: 5);

    timeline.length.should eq(2)

  end
end

describe Timeline, "#get" do
  it "should get a collection of users at a certain point in time" do
    t=Timeline.new
    t.add(time: 3.days.ago, followee: 2, action: :follow, follower: 1)
    t.add(time: 2.days.ago, followee: 3, action: :follow, follower: 1)
    t.add(time: 1.days.ago, followee: 4, action: :follow, follower: 1)
    t.add(time: Time.now,   followee: 5, action: :follow, follower: 1)
    ########### end setup

    friends=t.get(Time.now, 1)
    friend=friends[0]
    friend.timestamp.day.should eq 3.days.ago.day
    friend.id.should eq 2
  end
end

describe Friendship do
  it "should work w/ set logic" do
    f1=Friendship.new
    f1.id=1
    f1.timestamp=3.days.ago

    f2=Friendship.new
    f2.id=1
    f2.timestamp=5.days.ago

    f3=Friendship.new
    f3.id=2
    f3.timestamp=10.days.ago

    a=[f1]
    b=[f2, f3]

    inter = b & a
    
    inter.should eq [f1]

  end
end
