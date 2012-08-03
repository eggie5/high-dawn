$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'models'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'high-dawn'
require 'user'
require 'friendship'
require 'model'

REDIS=Redis.new(db: 1)

include HighDawn

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:suite) do
    puts "before suite"
    r=REDIS
    p r.flushdb
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
  long_user=User.new 1
  (2..10).each do |i|
    long_user.add_friend(today-day*i,  i)
  end

  #add follers
  long_user.add_follower(5.days.ago, 3)
  long_user.save

  long_user
end

def get_user2
  u=User.new 1
  u.add_friend(10.days.ago,  4)
  u.add_friend(10.days.ago, 5)
  u.save
  u
end

def get_user3
  u=User.new 1

  today=now=Time.now
  day=86400

  u.add_friend(3.days.ago, 2)
  u.remove_friend(2.days.ago, 2) #unfollow
  u.add_friend(1.day.ago, 5) # a day ago
  u.add_friend(now, 4)
  u.save
  u
end


def user_with_bro_who_has_tweets
  u=User.new 199983
  u.add_friend 4
  u.add_friend 5
  u.add_follower 4
  u.save
  u
end

def get_user4()
  u=User.new 7
  now=Time.now
  day=86400
  u.add_friend(3.days.ago, 2)
  u.add_friend(2.days.ago, 3)
  u.add_friend(1.day.ago, 5) # a day ago
  u.add_friend(now,  4)
  u.add_friend(3.days.ago,6)
  u.add_friend(2.days.ago,7)
  u.add_friend(1.day.ago,  8) # a day ago
  u.add_friend(now,      9)
  u.save
  u
end