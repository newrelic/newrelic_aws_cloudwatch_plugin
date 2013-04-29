require "rubygems"
require "bundler/setup"

require "newrelic_plugin"
require "newrelic_aws/config"
require "newrelic_aws/components"
require "newrelic_aws/collectors"

module NewRelicAWS
  module EC2
    class Agent < NewRelic::Plugin::Agent::Base

      agent_guid "com.newrelic.aws.ec2_overview"
      agent_version "0.0.1"
      agent_human_labels("EC2 Overview") { "EC2 Overview" }

      def setup_metrics
        options = Config.options
        @collectors = []
        options["regions"].each do |region|
          @collectors << Collectors::EC2.new(options["access_key"], options["secret_key"], region)
        end
        @components = Components::Collection.new("com.newrelic.aws.ec2", version)
      end

      def poll_cycle
        @collectors.each do |collector|
          collector.collect.each do |component, metric_name, units, value|
            report_metric("#{component}/#{metric_name}", units, value)
            @components.report_metric(component, metric_name, units, value)
          end
        end
        @components.process
      end
    end
  end

  module RDS
    class Agent < NewRelic::Plugin::Agent::Base

      agent_guid "com.newrelic.aws.rds_overview"
      agent_version "0.0.1"
      agent_human_labels("RDS Overview") { "RDS Overview" }

      def setup_metrics
        @collector = Collectors::RDS.new
        @components = Components::Collection.new("com.newrelic.aws.rds", version)
      end

      def poll_cycle
        @collector.collect.each do |component, metric_name, units, value|
          report_metric("#{component}/#{metric_name}", units, value)
          @components.report_metric(component, metric_name, units, value)
        end
        @components.process
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
