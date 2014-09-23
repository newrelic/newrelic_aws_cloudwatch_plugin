require "rubygems"
require "bundler/setup"

require "newrelic_plugin"
require "newrelic_aws/components"
require "newrelic_aws/collectors"
require 'newrelic_aws/version'

# AWS SDK debug logging
if NewRelic::Plugin::Config.config.newrelic['verbose'].to_i > 1
  AWS.config(
    :logger => NewRelic::PlatformLogger,
    :log_level => :debug
  )
end

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

  def self.agent_options_exist?(agent_options)
    # agent is commented out when options are nil
    !agent_options.nil?
  end

  def self.get_enabled_option(agent_options)
    if agent_options['enabled'].nil?
      true
    else
      agent_options['enabled']
    end
  end

  def self.agent_enabled?(agent)
    enabled = false
    agent_options = NewRelic::Plugin::Config.config.agents[agent.to_s]
    if NewRelicAWS::agent_options_exist?(agent_options)
      enabled = NewRelicAWS::get_enabled_option(agent_options)
    end
    enabled
  end

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
        if aws.is_a?(Hash)
          if aws["use_aws_metadata"] == true
            @agent_options["aws"] = {
              "use_aws_metadata" => true,
              "access_key" => nil,
              "secret_key" => nil
            }
          else
            unless aws["access_key"].is_a?(String) &&
                aws["secret_key"].is_a?(String)
              raise NewRelic::Plugin::BadConfig, "Missing or invalid AWS configuration."
            end
          end
        else
          raise NewRelic::Plugin::BadConfig, "Missing or invalid AWS configuration."
        end
        @agent_options
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
          NewRelic::PlatformLogger.info("Creating a #{agent_name} metrics collector for region: #{region}")
          @collectors << collector_class.new(
            agent_options["aws"]["access_key"],
            agent_options["aws"]["secret_key"],
            region,
            agent_options["agents"][agent_name]
          )
        end
        @components_collection = Components::Collection.new("com.newrelic.aws.#{agent_name}", NewRelicAWS::VERSION)
        @context = NewRelic::Binding::Context.new(NewRelic::Plugin::Config.config.newrelic['license_key'])
        @context.version = NewRelicAWS::VERSION
      end

      def poll_cycle
        request = @context.get_request
        start_time = Time.now
        NewRelic::PlatformLogger.debug("############## start poll_cycle ############")
        metric_count = 0
        @collectors.each do |collector|
          collector.collect.each do |component_name, metric_name, unit, value|
            component = @context.get_component(component_name, @components_collection.guid)
            @components_collection.report_metric(request, component, metric_name, unit, value) unless component.nil?
            metric_count += 1
          end
        end
        NewRelic::PlatformLogger.debug("#{metric_count} metrics collected in #{Time.now - start_time} seconds")
        NewRelic::PlatformLogger.debug("############## end poll_cycle ############")
        request.deliver
      end
    end
  end

  module EC2
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ec2"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("EC2") { "EC2" }
    end
  end

  module EBS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ebs"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("EBS") { "EBS" }
    end
  end

  module ELB
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.elb"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("ELB") { "ELB" }
    end
  end

  module RDS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.rds"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("RDS") { "RDS" }
    end
  end

  module DDB
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ddb"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("DynamoDB") { "DynamoDB" }
    end
  end

  module SQS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.sqs"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("SQS") { "SQS" }
    end
  end

  module SNS
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.sns"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("SNS") { "SNS" }
    end
  end

  module EC
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ec"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("ElastiCache") { "ElastiCache" }
    end
  end

  module ECR
    class Agent < Base::Agent
      agent_guid "com.newrelic.aws.ecr"
      agent_version NewRelicAWS::VERSION
      agent_human_labels("ElastiCacheRedis") { "ElastiCacheRedis" }
    end
  end

  #
  # Register each agent with the component.
  #
  NewRelic::Plugin::Setup.install_agent :ec2, EC2 if NewRelicAWS::agent_enabled?(:ec2)
  NewRelic::Plugin::Setup.install_agent :ebs, EBS if NewRelicAWS::agent_enabled?(:ebs)
  NewRelic::Plugin::Setup.install_agent :elb, ELB if NewRelicAWS::agent_enabled?(:elb)
  NewRelic::Plugin::Setup.install_agent :rds, RDS if NewRelicAWS::agent_enabled?(:rds)
  # NewRelic::Plugin::Setup.install_agent :ddb, DDB # WIP
  NewRelic::Plugin::Setup.install_agent :sqs, SQS if NewRelicAWS::agent_enabled?(:sqs)
  NewRelic::Plugin::Setup.install_agent :sns, SNS if NewRelicAWS::agent_enabled?(:sns)
  NewRelic::Plugin::Setup.install_agent :ec,  EC  if NewRelicAWS::agent_enabled?(:ec)
  NewRelic::Plugin::Setup.install_agent :ecr, ECR if NewRelicAWS::agent_enabled?(:ecr)

  #
  # Launch the agents; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run
end
