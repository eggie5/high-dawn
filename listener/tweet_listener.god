require 'rubygems'
require 'twitter'

p File.dirname(__FILE__)
p "env=#{ENV['HD_ENV']}"

God.watch do |w|
  w.name = "tweet_listener"
  w.dir = File.dirname(__FILE__)
  w.start = "bundle exec ruby ./runner.rb"
  #w.log = '/var/log/myprocess.log'
  w.keepalive(:memory_max => 150.megabytes,
  :cpu_max => 50.percent)

  w.transition(:up, :start) do |on|
    on.condition(:process_exits) do |c|
      c.notify = 'eggie5'
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

# token: 155416821-GxjA7UDy0gh4WGduZGljPwBjmIpmujFOE3TRAZYd
#       secret: gDjoY0IH8EUV8nrmWKLIDRxPLJM8NbroT06K35KO8U
God.contact(:twitter) do |c|
  c.name = 'eggie5'
  c.consumer_token = 'gOhjax6s0L3mLeaTtBWPw'  # default for god
  c.consumer_secret = 'yz4gpAVXJHKxvsGK85tEyzQJ7o2FEy27H1KEWL75jfA'  #default for god
  c.access_token = '758758610-K4rH4tVJnshaVe3yQIoytCmE1fNpMntMX0pRcTPq'
  c.access_secret = 'qqt6iHEdRkltFSOT1e8Svsy7IVbX0cY8JK72S1Ig'
end


#hack the twitter plugin in GOD to use the new Gem syntax
module God
  module Contacts
    class Twitter < Contact
      def notify(message, time, priority, category, host)
        ::Twitter.configure do |config|
          config.consumer_key = consumer_token
          config.consumer_secret = consumer_secret
          config.oauth_token = access_token
          config.oauth_token_secret = access_secret
        end

        ::Twitter.update(message)

        self.info = "sent twitter update"
      rescue => e
        applog(nil, :info, "failed to send twitter update: #{e.message}")
        applog(nil, :debug, e.backtrace.join("\n"))
      end
    end
  end
end
