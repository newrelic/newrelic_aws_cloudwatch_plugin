require "rubygems"
require "bundler/setup"

require "newrelic_plugin"
require "newrelic_aws/components"
require "newrelic_aws/collectors"

module NewRelicAWS
  module Base
    class Agent < NewRelic::Plugin::Agent::Base
      def agent_name
        self.class.name.split("::")[-2].downcase
      end

      def collector_class
        Collectors.const_get(agent_name.upcase)
      end

      def agent_options
        return @agent_options if @agent_options
        @agent_options = NewRelic::Plugin::Config.config.options
        aws = @agent_options["aws"]
        unless aws.is_a?(Hash) &&
            aws["access_key"].is_a?(String) &&
            aws["secret_key"].is_a?(String) &&
            aws["regions"].is_a?(Array)
          raise NewRelic::Plugin::BadConfig, "Missing or invalid AWS configuration."
        end
        @agent_options
      end

      def overview_enabled?
        !!agent_options["agents"][agent_name][:overview]
      end

      def setup_metrics
        @collectors = []
        agent_options["aws"]["regions"].each do |region|
          @collectors << collector_class.new(
            agent_options["aws"]["access_key"],
            agent_options["aws"]["secret_key"],
            region
          )
        end
        @components = Components::Collection.new("com.newrelic.aws.#{agent_name}", version)
      end

      def poll_cycle
        @collectors.each do |collector|
          collector.collect.each do |component, metric_name, unit, value, timestamp|
            @components.report_metric(component, metric_name, unit, value)
            if overview_enabled?
              report_metric("#{component}/#{metric_name}", unit, value)
            end
          end
        end
        @components.process
      end
    end
  end

  module EC2
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ec2_overview"
      agent_version "0.0.1"
      agent_human_labels("EC2 Overview") { "EC2 Overview" }
    end
  end

  module EBS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ebs_overview"
      agent_version "0.0.1"
      agent_human_labels("EBS Overview") { "EBS Overview" }
    end
  end

  module RDS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.rds_overview"
      agent_version "0.0.1"
      agent_human_labels("RDS Overview") { "RDS Overview" }
    end
  end

  module DDB
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ddb_overview"
      agent_version "0.0.1"
      agent_human_labels("DynamoDB Overview") { "DynamoDB Overview" }
    end
  end

  module SQS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.sqs_overview"
      agent_version "0.0.1"
      agent_human_labels("SQS Overview") { "SQS Overview" }
    end
  end

  module SNS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.sns_overview"
      agent_version "0.0.1"
      agent_human_labels("SNS Overview") { "SNS Overview" }
    end
  end

  module EC
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ec_overview"
      agent_version "0.0.1"
      agent_human_labels("ElastiCache Overview") { "ElastiCache Overview" }
    end
  end

  #
  # Register each agent with the component.
  #
  NewRelic::Plugin::Setup.install_agent :ec2, EC2
  NewRelic::Plugin::Setup.install_agent :ebs, EBS
  NewRelic::Plugin::Setup.install_agent :rds, RDS
  NewRelic::Plugin::Setup.install_agent :ddb, DDB
  NewRelic::Plugin::Setup.install_agent :sqs, SQS
  NewRelic::Plugin::Setup.install_agent :sns, SNS
  NewRelic::Plugin::Setup.install_agent :ec, EC

  #
  # Launch the agents; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run
end
