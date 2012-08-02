#this will take a 

require 'iron_worker' # or resque - not sure yet.

class TweetWorker < IronWorker::Base

  attr_accessor :max

  def run
    
  end
end