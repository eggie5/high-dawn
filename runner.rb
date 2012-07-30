require './models/user'
require 'ap'

#write example
def write
u=User.new;u.id=1
u.add_friend(3)
u.add_friend(100)
u.add_follower(2)

u.save
end


#read example
def _read
  u=User.find(1)
  u.friends
  ap u
  
end

write
