#!/usr/bin/env ruby

#
# Start
# - bundle exec bin/daemon.rb start
#
# Stop
# - bundle exec bin/daemon.rb stop
#

require 'rubygems'
require 'daemons'
Daemons.run('./bin/newrelic_aws')