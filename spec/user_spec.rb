require './spec/spec_helper'

describe User do

  it "should show date someone followed me" do
    u=get_user2()
    id=4
    ts=5.days.ago
    u.add_follower(ts, id) 
    #added a follower 5 days ago

    followers = u.followers(at: Time.now)
    follower=followers.first
    follower.id.should eq id
    
    follower.timestamp.day.should eq ts.day
  end

  it "should show when somebody became a bro" do
    u=User.new
    u.id=1
    u.add_friend(10.days.ago, 2)
    u.add_friend(8.days.ago, 3)
    u.add_friend(6.days.ago, 4)
    id=3
    u.add_follower(5.days.ago, id)
    u.add_friend(4.days.ago, 5)


    bros=u.bros(at: Time.now) #accumulated collection as of NOW
    bros.length.should eq 1

    bro=u.bros.first
    bro.id.should eq id

  end

  it "should show current bros" do
    u=User.new
    u.id=me=1
    u.add_friend( 4)
    u.add_friend( 5)
    u.add_follower(4)


    friends = u.friends(at: Time.now)
    followers = u.followers(at: Time.now)
    bros=u.bros(at: Time.now)

    bros.length.should eq 1
    p "bros= #{bros}"
    bros[0].id.should eq 4
  end

  it "should show current non-bros" do
    u=User.new
    u.id=me=1
    u.add_friend(4)
    u.add_friend(5)
    u.add_follower(4)


    friends = u.friends(at: Time.now)
    followers = u.followers(at: Time.now)
    nbs=u.non_bros(at: Time.now)

    nbs.length.should eq 1
    nbs[0].id.should eq 5
  end

  it "should add followers" do
    u=User.new
    u.add_follower(3.days.ago, 2)
    u.add_follower(2.days.ago,  2)
    u.add_follower(1.day.ago,   5) # a day ago
    u.add_follower(4) #now

    u.followers.length.should eq 4


  end

  it "should have a current list of friends" do

    u=get_user4();

    u.friends(at: Time.now).length.should eq 8

  end


  it "should get a list of friends/followers on certain date" do
    u=user1
    
    u.friends(at: 3.days.ago).length.should eq 1 # accumulated collection as of 3 days ago
    u.friends(at: 2.days.ago).length.should eq 0
    u.friends(at: 1.day.ago).length.should eq 1

    friends= u.friends(at: Time.now) # accumulated collection as of NOW
    friends.ids.should eq [5,4]
    friends.ids.length.should eq 2

  end

end

def user1
  u=User.new
  u.id=1
  u.add_friend(3.days.ago, 2)
  u.remove_friend(2.days.ago, 2) #unfollow
  u.add_friend(1.day.ago, 5) # a day ago
  u.add_friend(4) #now
  u
end
