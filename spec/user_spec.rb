require './spec/spec_helper'
require 'ap'

def user_with_bro_who_has_tweets
  u=User.new
  u.id=me=1
  u.add_friend 4
  u.add_friend 5
  u.add_follower 4
  u
end

describe User do

  it "UC #3 - bro should have associated tweets" do
    u=user_with_bro_who_has_tweets

    bro=u.bros(at: Time.now).first

    #check for all tweets to this bro
    bro.tweets.length.should eq 0
  end

  it "UC #2 - should show date someone followed me" do
    u=get_user2()
    new_follower=f={id:4, ts:5.days.ago}
    u.add_follower(f[:ts], f[:id])
    #added a follower 5 days ago

    follower = u.followers.first
    follower.id.should eq new_follower[:id]

    follower.timestamp.day.should eq new_follower[:ts].day
  end

  it "UC #1 - should show when somebody became a bro" do
    u=User.new; u.id=1
    u.add_friend(10.days.ago, 2)
    u.add_friend(8.days.ago, 3)
    u.add_friend(6.days.ago, 4)

    #no bros at first
    u.bros.length.should eq 0
    #now follow me back to make 3 a bro
    id=3; at=5.days.ago
    u.add_follower(at, id)

    u.bros.length.should eq 1

    bro=u.bros.first
    bro.id.should eq id
    bro.timestamp.strftime("%Y.%m.%d").should eq at.strftime("%Y.%m.%d")

  end

  it "should show current bros" do
    u=User.new
    u.id=me=1
    u.add_friend( 4)
    u.add_friend( 5)
    
    u.bros.length.should eq 0
    
    u.add_follower(id1=4)
    u.add_follower(id2=5)
    
    bros=u.bros

    bros.length.should eq 2
    bros[0].id.should eq id1
    bros[1].id.should eq id2
    
  end

  it "should show current non-bros" do
    u=User.new
    u.id=me=1
    u.add_friend(4)
    u.add_friend(5)
    u.add_follower(4)

    nbs=u.non_bros()

    nbs.length.should eq 1
    nbs[0].id.should eq 5
  end

  it "should add/remove followers" do
    u=User.new
    u.add_follower(3.days.ago, 2)
    u.add_follower(2.days.ago,  3)
    u.add_follower(1.day.ago,   5) # a day ago
    u.add_follower(4) #now

    u.followers.length.should eq 4
    
    u.remove_follower(4)
    u.remove_follower(5)
    u.remove_follower(3)    
    u.remove_follower(2)    
    u.followers.length.should eq 0

  end

  it "should have a current list of friends" do
    u=get_user4();

    u.friends.length.should eq 8

  end


  it "should get a list of friends/followers on certain date" do
    u=user1

    u.friends(at: 3.days.ago).length.should eq 1 # accumulated collection as of 3 days ago
    u.friends(at: 2.days.ago).length.should eq 0
    u.friends(at: 1.day.ago).length.should eq 1

    friends= u.friends(at: Time.now) # accumulated collection as of NOW

    friends.ids.should eq [5,4]

  end
  
  it "should show the data structure" do
    u=User.new;u.id=1
    u.add_friend(10.days.ago,2)
    u.add_friend(7.days.ago,3)
    u.add_follower(6.days.ago, 4)
    u.add_friend(6.days.ago, 23)
    u.add_friend(6.days.ago, 33);
    u.remove_friend(5.days.ago, 2)
    
    ap u
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
