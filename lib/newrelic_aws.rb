require "rubygems"
require "bundler/setup"

require "newrelic_plugin"
require "newrelic_aws/collectors"

module NewRelicAWS
  module Config
    def self.options
      options = NewRelic::Plugin::Config.config.config["aws"]
      unless options.is_a?(Hash) &&
          options.has_key?("access_key") &&
          options.has_key?("secret_key")
        raise NewRelic::Plugin::BadConfig, "Missing or invalid AWS configuration."
      end
      options
    end
  end

  module EC2
    class Agent < NewRelic::Plugin::Agent::Base

      agent_guid "com.newrelic.aws.ec2"
      agent_version "0.0.1"
      agent_human_labels("AWS EC2") { "AWS EC2" }

      def setup_metrics
        @collector = NewRelicAWS::Collectors::EC2.new(Config.options)
      end

      def poll_cycle
        puts @collector.inspect
        #metrics = @collector.collect!
        #metrics.each do |*args|
        #  report_metric args
        #end
      end
    end
  end

  module RDS
    class Agent < NewRelic::Plugin::Agent::Base

      agent_guid "com.newrelic.aws.rds"
      agent_version "0.0.1"
      agent_human_labels("AWS RDS") { "AWS RDS" }

      def poll_cycle
        x = Time.now.to_f * 1000 * Math::PI * 2
        report_metric "SIN",     "Value", Math.sin(x) + 1.0
        report_metric "COS",     "Value", Math.cos(x) + 1.0
        report_metric "BIASSIN", "Value", Math.sin(x) + 5.0
      end
    end
  end

  #
  # Register each agent with the component.
  #
  NewRelic::Plugin::Setup.install_agent :ec2, EC2
  NewRelic::Plugin::Setup.install_agent :rds, RDS

  #
  # Launch the agents; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run
end
