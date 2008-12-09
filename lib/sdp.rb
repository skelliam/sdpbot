require 'rubygems'
require 'yaml'
require 'cache'
require 'logging'

$config = YAML.load_file(File.join(File.dirname(__FILE__), '/../config/systems.yaml'))

require 'dekiwiki'
require 'mediawiki'
require 'action_view_helper'

require 'bugzilla'
include Bugzilla

require 'sdp/numeric_helper'
require 'sdp/date_helper'
require 'sdp/string_helper'
require 'sdp/calendar'

require 'sdp/engineer'
require 'sdp/project'
require 'sdp/iteration'
require 'sdp/release'
require 'sdp/releases'
require 'sdp/notifier'
require 'sdp/personel'
require 'sdp/velocity'

include SDP

Personel.load

