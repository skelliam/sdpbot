$LOAD_PATH.push(File.join(File.dirname(__FILE__), "."))
$LOAD_PATH.push(File.join(File.dirname(__FILE__), "../lib"))
$LOAD_PATH.push(File.join(File.dirname(__FILE__), "../vendor/ruby-cache/lib"))

require 'sdp'

require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end