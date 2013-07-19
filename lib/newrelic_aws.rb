require "rubygems"
require "bundler/setup"

require "newrelic_plugin"
require "newrelic_aws/logger"
require "newrelic_aws/components"
require "newrelic_aws/collectors"

module NewRelicAWS
  AWS_REGIONS = %w[
    us-east-1
    us-west-1
    us-west-2
    eu-west-1
    ap-southeast-1
    ap-southeast-2
    ap-northeast-1
    sa-east-1
  ]

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
            aws["secret_key"].is_a?(String)
          raise NewRelic::Plugin::BadConfig, "Missing or invalid AWS configuration."
        end
        @agent_options
      end

      def self.overview_available(available=false)
        @overview_available ||= available
      end

      def overview_enabled?
        self.class.overview_available ? !!agent_options["agents"][agent_name][:overview] : false
      end

      def aws_regions
        if agent_options["aws"]["regions"]
          Array(agent_options["aws"]["regions"])
        else
          AWS_REGIONS
        end
      end

      def setup_metrics
        @collectors = []
        aws_regions.each do |region|
          Logger.write("Creating a #{agent_name} metrics collector for region: #{region}")
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
      agent_version "2.1.0"
      agent_human_labels("EC2") { "EC2" }
      overview_available true
    end
  end

  module EBS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ebs_overview"
      agent_version "2.1.0"
      agent_human_labels("EBS") { "EBS" }
      overview_available true
    end
  end

  module ELB
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.elb_overview"
      agent_version "2.1.0"
      agent_human_labels("ELB") { "ELB" }
    end
  end

  module RDS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.rds_overview"
      agent_version "2.1.0"
      agent_human_labels("RDS") { "RDS" }
    end
  end

  module DDB
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ddb_overview"
      agent_version "2.1.0"
      agent_human_labels("DynamoDB") { "DynamoDB" }
    end
  end

  module SQS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.sqs_overview"
      agent_version "2.1.0"
      agent_human_labels("SQS") { "SQS" }
    end
  end

  module SNS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.sns_overview"
      agent_version "2.1.0"
      agent_human_labels("SNS") { "SNS" }
    end
  end

  module EC
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ec_overview"
      agent_version "2.1.0"
      agent_human_labels("ElastiCache") { "ElastiCache" }
    end
  end

  module SWF
    class Agent < Base::Agent
        agent_guid "com.newrelic.aws.swf"
        agent_version "7/13"
        agent_human_labels("SWF") { "SWF" }
        overview_available true
    end
  end

  #
  # Register each agent with the component.
  #
  NewRelic::Plugin::Setup.install_agent :ec2, EC2
  NewRelic::Plugin::Setup.install_agent :ebs, EBS
  NewRelic::Plugin::Setup.install_agent :elb, ELB
  NewRelic::Plugin::Setup.install_agent :rds, RDS
  # NewRelic::Plugin::Setup.install_agent :ddb, DDB # WIP
  NewRelic::Plugin::Setup.install_agent :sqs, SQS
  NewRelic::Plugin::Setup.install_agent :sns, SNS
  NewRelic::Plugin::Setup.install_agent :ec, EC
  NewRelic::Plugin::Setup.install_agent :swf, SWF


  #
  # Launch the agents; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run
end
