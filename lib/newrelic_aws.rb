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
        data_points = @collector.collect!
        data_points.each do |point|
          report_metric *point
        end
      end
    end
  end

  module RDS
    class Agent < NewRelic::Plugin::Agent::Base

      agent_guid "com.newrelic.aws.rds"
      agent_version "0.0.1"
      agent_human_labels("AWS RDS") { "AWS RDS" }

      def setup_metrics
        @collector = NewRelicAWS::Collectors::RDS.new(Config.options)
      end

      def poll_cycle
        data_points = @collector.collect!
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
