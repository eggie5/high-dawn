require 'twitter'
require 'ap'

s= Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"
puts s

user_handle="rolandal"
user_id = Twitter.user(user_handle).id

bros=[]
not_bros=[]

following=Twitter.friend_ids(user_id)
following.ids.each do |id|
  #include? is just a for loop
  #so this is a for loop in a for loop
  #i.e. On^2 quadratic growth -- super slow!
  puts id
  begin
  if Twitter.friend_ids(id).ids.include?(user_id)
    bros.push id
  else
    not_bros.push id
  end
  rescue Exception => na
    puts "na exception.. skipping"
  end
end

p "@#{user_handle} is following #{following.ids.length} people of which "
p "#{bros.lenght} are following him back and #{not_bros.length} are not."


# following=Twitter.friend_ids("rolandal")
# following.ids.each do |id|
#   puts id
# end
# followers=Twitter.follower_ids("rolandal")
# 


# frc=Twitter.user("rolandal").friends_count
# ap "@rolandal is following #{frc} people,"
# 
# foc=Twitter.user("rolandal").followers_count
# ap "but only has #{foc} followers"
# 
# delta=frc-foc
# ap "#{delta} people are not following him back..."


# ap Twitter.friendship('stevewoz', 'eggie5')