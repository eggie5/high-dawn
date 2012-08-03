require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Friendship do
  it "should have many tweets" do
    f=Friendship.new;f.id=1;f.timestamp=3.days.ago
  end
end

describe FriendshipCollection do
  it "should act like normal array" do
    f1=Friendship.new
    f1.id=1
    f1.timestamp=3.days.ago
    f2=Friendship.new
    f2.id=1
    f2.timestamp=5.days.ago
    f3=Friendship.new
    f3.id=2
    f3.timestamp=10.days.ago

    a=FriendshipCollection.new
    a.class.should eq FriendshipCollection
    a.push f1
    a.push f2
    a.push f3

    a.length.should eq 3
    a.ids.should eq [1,1,2]
  end

  it "should do array subtract" do
    #assume friends from time A
    f1=Friendship.new
    f1.id=1
    f1.timestamp=10.days.ago
    a=FriendshipCollection.new
    a.push f1

    #assume frinds from time B
    f2=Friendship.new
    f2.id=1
    ts=5.days.ago
    f2.timestamp=ts

    f3=Friendship.new
    f3.id=2
    f3.timestamp=3.days.ago

    b=FriendshipCollection.new
    b.push f2
    b.push f3

    #any new friends
    new_friends=b-a

    new_friends.length.should eq 1
    new_friends.first.id.should eq 2
  end
end
