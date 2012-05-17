require 'twitter'
require 'ap'



friends=Twitter.friend_ids("rolandal")
followers=Twitter.follower_ids("rolandal")



frc=Twitter.user("rolandal").friends_count
ap "@rolandal is following #{frc} people,"

foc=Twitter.user("rolandal").followers_count
ap "but only has #{foc} followers"

delta=frc-foc
ap "#{delta} people are not following him back..."