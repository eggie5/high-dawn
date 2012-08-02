$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'high-dawn'

include HighDawn

u=User.new; u.id=155416821
p u.bros.ids