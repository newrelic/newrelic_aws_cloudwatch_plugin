module NewRelicAWS
  module Collectors
    class ELB < Base
      def load_balancers
        @elb = AWS::ELB.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        @elb.load_balancers.map { |load_balancer| load_balancer.name }
      end

      def define_component_names 
        if @component_name_option
          return get_metric_options(@s3_bucket,@component_names)
        end
      end

      def metric_list
        [
          ["Latency", "Average", "Seconds"],
          ["RequestCount", "Sum", "Count", 0],
          ["HealthyHostCount", "Maximum", "Count", 0],
          ["UnHealthyHostCount", "Maximum", "Count", 0],
          ["HTTPCode_ELB_4XX", "Sum", "Count", 0],
          ["HTTPCode_ELB_5XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_2XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_3XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_4XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_5XX", "Sum", "Count", 0],
          ["BackendConnectionErrors", "Sum", "Count", 0],
          ["SurgeQueueLength", "Maximum", "Count", 0],
          ["SpilloverCount", "Sum", "Count", 0]
        ]
      end

      def elb_component_name(elb_name)
        begin
          response = @elb.client.describe_tags( :load_balancer_names => [elb_name] )
          name_tag = response[:tag_descriptions].first[:tags].find { |tag| tag[:key] == 'Name' }
          elb_name = name_tag.nil? ? elb_name : name_tag[:value]
          return elb_name
        rescue => error
            NewRelic::PlatformLogger.error("Unexpected error: " + error.message)
            NewRelic::PlatformLogger.debug("Backtrace: " + error.backtrace.join("\n "))
          raise error
        end
      end

      def collect
        common_names = define_component_names
        data_points = []
        app_name = nil
        load_balancers.each do |load_balancer_name|
          name_tag = elb_component_name(load_balancer_name)
          if name_tag.nil? then
            next
          end
          unless common_names.nil?
            JSON.parse(common_names).each do |common_name|
              case name_tag.to_s
              when /#{common_name['condition']}/
                app_name = common_name['app_name']
                break
              else
                next
              end
            end
            if app_name.nil? then
              next
            end
          end
          metric_list.each do |(metric_name, statistic, unit, default_value)|
            data_point = get_data_point(
              :namespace     => "AWS/ELB",
              :metric_name   => metric_name,
              :statistic     => statistic,
              :unit          => unit,
              :default_value => default_value,
              :dimension     => {
                :name  => "LoadBalancerName",
                :value => load_balancer_name
              },
              :component_name => app_name.nil? ? load_balancer_name : "#{app_name}"
            )
            NewRelic::PlatformLogger.debug("metric_name: #{metric_name}, statistic: #{statistic}, unit: #{unit}, response: #{data_point.inspect}")
            unless data_point.nil?
              data_points << data_point
              puts data_point
            end
          end
        end
        data_points
      end
    end
  end
end
