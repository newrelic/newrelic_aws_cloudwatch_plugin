module NewRelicAWS
  module Collectors
    class ELB < Base
      def load_balancers
        elb = AWS::ELB.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        elb.load_balancers.map { |load_balancer| load_balancer.name }
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

      def collect
        data_points = []
        load_balancers.each do |load_balancer_name|
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
              }
            )
            NewRelic::PlatformLogger.debug("metric_name: #{metric_name}, statistic: #{statistic}, unit: #{unit}, response: #{data_point.inspect}")
            unless data_point.nil?
              data_points << data_point
            end
          end
        end
        data_points
      end
    end
  end
end
