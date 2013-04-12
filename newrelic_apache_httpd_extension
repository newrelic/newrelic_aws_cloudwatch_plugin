#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "newrelic_plugin"
require "net/http"

#
#
# The entire agent should be enclosed in a "ApacheHTTPDAgent" module
#
module ApacheHTTPDAgent

  #
  # Agent, Metric and PollCycle classes
  #
  # Each agent module must have an Agent, Metric and PollCycle class that inherits from their
  # Component counterparts as you can see below.
  #
  class Agent < NewRelic::Plugin::Agent::Base
	
   		
	agent_config_options :hostname, :username, :password, :port, :agent_name
    agent_guid "com.newrelic.examples.apache.httpd"
    agent_version "0.0.1"
	    
    #
    # Each agent class must also include agent_human_labels. agent_human_labels requires:
    # A friendly name of your component to appear in graphs.
    # A block that returns a friendly name for this instance of your component.

    # The block runs in the context of the agent instance.
    #
    agent_human_labels("ApacheHTTPD") { "#{hostname}" }

    def setup_metrics
    	@@APACHE_STAT_URL = URI.parse("http://#{hostname}/server-status?auto")
		@@metric_types = Hash.new("ms")  
	    @@metric_types["Total Accesses"] = "accesses"
		@@metric_types["Total kBytes"] = "kb"
		@@metric_types["CPULoad"] = "%"
		@@metric_types["Uptime"] = "sec"
		@@metric_types["ReqPerSec"] = "requests"
		@@metric_types["BytesPerSec"] = "bytes/sec"
		@@metric_types["BytesPerReq"] = "bytes/req"
		@@metric_types["BusyWorkers"] = "workers"
		@@metric_types["IdleWorkers"] = "workers"
		@@metric_types["ConnsTotal"] = "connections"
		@@metric_types["ConnsAsyncWriting"] = "connections"
		@@metric_types["ConnsAsyncKeepAlive"] = "connections"
		@@metric_types["ConnsAsyncClosing"] = "connections"
		@@metric_types["Scoreboard/WaitingForConnection"] = "workers"
		@@metric_types["Scoreboard/StartingUp"] = "workers"
		@@metric_types["Scoreboard/ReadingRequest"] = "workers"
		@@metric_types["Scoreboard/SendingReply"] = "workers"
		@@metric_types["Scoreboard/KeepAliveRead"] = "workers"
		@@metric_types["Scoreboard/DNSLookup"] = "workers"
		@@metric_types["Scoreboard/ClosingConnection"] = "workers"
		@@metric_types["Scoreboard/Logging"] = "workers"
		@@metric_types["Scoreboard/GracefullyFinishing"] = "workers"
		@@metric_types["Scoreboard/IdleCleanupOfWorker"] = "workers"
		@@metric_types["Scoreboard/OpenSlotWithNoCurrentProcess"] = "workers"
 		@@scoreboard_values = Hash["_", "WaitingForConnection", "S", "StartingUp", "R", "ReadingRequest", "W", "SendingReply", "K", "KeepAliveRead", "D", "DNSLookup", "C", "ClosingConnection", "L", "Logging", "G", "GracefullyFinishing", "I", "IdleCleanupOfWorker", ".", "OpenSlotWithNoCurrentProcess"]
    end

    def poll_cycle
      stats = apache_httpd_stats()
      stats.each_key { |mtree| 
      	mout = "HTTPD/#{hostname}"
      	if "#{mtree}".start_with?("Scoreboard")
      		mout = "#{mout}/#{mtree}"
      	elsif @@metric_types[mtree] == "workers"
      		mout = "#{mout}/Workers/#{mtree}"
      	elsif @@metric_types[mtree] == "connections"
      		mout = "#{mout}/Connections/#{mtree}"
      	elsif @@metric_types[mtree] == "%"
      		stats[mtree] = 100 * stats[mtree].to_f
      		mout = "#{mout}/#{mtree}"
      	else 
      		mout = "#{mout}/#{mtree}"
      	end
      	report_metric "#{mout}", @@metric_types[mtree], stats[mtree]
      	# puts("#{mout} | #{@@metric_types[mtree]} | #{stats[mtree]}")	
      }
    rescue => e
      $stderr.puts "#{e}: #{e.backtrace.join("\n  ")}"
    end

    private
    
    def apache_httpd_stats	
	    begin
	    	resp = ::Net::HTTP.get_response(@@APACHE_STAT_URL)
	    rescue => e
	      $stderr.puts "#{e}: #{e.backtrace.join("\n  ")}"
	    end
      	data = resp.body
      	
      	lines = data.split("\n")
      	stats = Hash.new
        lines.each { |line| 
        	marray = line.split(": ")
        	# puts("mname: #{marray[0]} mvalue: #{marray[1]}")
        	if marray[0] == "Scoreboard"
        		@@scoreboard_values.each { |sk, sv| 
					mcount = marray[1].count sk
       				sn = "#{marray[0]}/#{sv}"
					stats[sn] = mcount 
				}
        	else
        		stats["#{marray[0]}"] = marray[1]
        	end
        }
		return stats
    end  
  end

  NewRelic::Plugin::Setup.install_agent :apachehttpd, self

  # Launch the agent; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run

end
