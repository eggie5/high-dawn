require './models/user'

describe User do

  it "should show current non-bros" do
    today=now=Time.now
    day=86400

    u=User.new
    me=3
    u.id=me

    u.friends.add(now, me, :follow, 4)
    u.non_bros.length.should eq 1

    u.friends.add(now, me, :follow, 5)
    u.non_bros.length.should eq 2
  end

  it "should have a followers timeline" do
    u=User.new
    today=now=Time.now
    day=86400

    u.followers.add(now-day*3, 3, :follow, 2)
    u.followers.add(now-day*2, 3, :unfollow, 2)
    u.followers.add(now-day,   3, :follow, 5) # a day ago
    u.followers.add(now,       3, :follow, 4)


  end

  it "should have a current list of friends" do

    u=User.new
    now=Time.now
    day=86400
    u.friends.add(now-day*3, 3, :follow, 2)
    u.friends.add(now-day*2, 3, :follow, 2)
    u.friends.add(now-day,   3, :follow, 5) # a day ago
    u.friends.add(now,       3, :follow, 4)
    u.friends.add(now-day*3, 3, :follow, 2)
    u.friends.add(now-day*2, 3, :follow, 2)
    u.friends.add(now-day,   3, :follow, 5) # a day ago
    u.friends.add(now,       3, :follow, 4)

    u.friends.length.should eq 8

  end

  it "should have a list of friends yesterday" do
    u=User.new

    today=now=Time.now
    day=86400

    u.friends.add(now-day*3, 3, :follow, 2)
    u.friends.add(now-day*2, 3, :unfollow, 2)
    u.friends.add(now-day,   3, :follow, 5) # a day ago
    u.friends.add(now,       3, :follow, 4)

    # 3 days ago
    u.friends(at: today-day*3).length.should eq 1

    #freinds day before yest
    u.friends(at: today-day*2).length.should eq 0

    #how check my friends on yesterday
    u.friends(at: today-day).length.should eq 1

    #friends now
    friends= u.friends(at: Time.now)
    friends.should eq [5,4]
    friends.length.should eq 2

  end
end
