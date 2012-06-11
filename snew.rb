ts=Time.now.to_i

t1_friends=[1,2,3]
t1_followers=[5,6,9]
t1_bros= t1_friends & t1_followers

t2_friends=[2,3]
t2_followers=[5,6,9]
t2_bros= t2_friends & t2_followers

new_friends=t2_friends-t1_friends
new_followers=t2_followers - t1_followers

unfriended = t1_friends - t2_friends
lost_followers = t1_followers - t2_followers

new_bros=t2_bros - t1_bros
lost_bros=t1_bros - t2_bros

p new_friends
p "I unfriended: #{unfriended}"
p new_followers
p lost_followers


diff= new_followers + unfriended + new_followers + lost_followers

if diff.empty?
  p "no diff"
else
  p "changes"
end
