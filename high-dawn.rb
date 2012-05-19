require 'twitter'
require 'ap'
require 'yaml'

s= Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"
puts s

#load creds from yaml
yaml = YAML.load_file("oauth.yaml")
Twitter.configure do |config|
  config.consumer_key = yaml["consumer_key"]
  config.consumer_secret = yaml["consumer_secret"]
  config.oauth_token = yaml["oauth_token"]
  config.oauth_token_secret = yaml["oauth_token_secret"]
end

user_handle="eggie5"
user_id = Twitter.user(user_handle).id

bros=[]
not_bros=[]

#get people youre following
following=Twitter.friend_ids(user_id)

relationships=[]
#feed following people to friendships/lookup twitter API
#only takes 100 id's at a time have to page results
(following.ids.length/100).times do |i|
  start_index=100*i
  end_index=99*(i+1)
  _relationships=Twitter.friendships(following.ids[start_index..end_index])
  relationships.concat _relationships
end

bros=[]
non_bros=[]

relationships.each do |relationship|
  if relationship.connections.include? "followed_by"
    bros.push relationship.name
  else
    non_bros.push relationship.name
  end
end

ap bros

ap non_bros


