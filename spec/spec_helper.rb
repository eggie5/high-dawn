require './models/user'
require './models/timeline'
require './models/model'
require 'active_support/all'
require 'redis'

RSpec.configure do |config|
  config.before(:suite) do
    puts "before suite"
    r=Redis.new
    p r.flushall
  end

  config.before(:all) do
  end

  config.before(:each) do
  end

  config.after(:each) do
  end

  config.after(:all) do
  end

  config.after(:suite) do
  end
end

def get_user1
  today=now=Time.now
  day=86400
  long_user=User.new
  long_user.id=1
  (2..10).each do |i|
    long_user.add_friend(today-day*i,  i)
  end

  #add follers
  long_user.add_follower(5.days.ago, 3)

  long_user
end

def get_user2
  u=User.new
  me=u.id=1
  u.add_friend(10.days.ago,  4)
  u.add_friend(10.days.ago, 5)
  
  u
end

def get_user3
  u=User.new
  u.id=1

  today=now=Time.now
  day=86400

  u.add_friend(3.days.ago, 2)
  u.remove_friend(2.days.ago, 2) #unfollow
  u.add_friend(1.day.ago, 5) # a day ago
  u.add_friend(now, 4)
  u
end

def get_user4()
  u=User.new
  u.id=7
  now=Time.now
  day=86400
  u.add_friend(3.days.ago, 2)
  u.add_friend(2.days.ago, 2)
  u.add_friend(1.day.ago, 5) # a day ago
  u.add_friend(now,  4)
  u.add_friend(3.days.ago,2)
  u.add_friend(2.days.ago,2)
  u.add_friend(1.day.ago,  5) # a day ago
  u.add_friend(now,      4)
  u
end
