module NewRelicAWS
  module Collectors
    class ALB < Base
      def load_balancers
        alb = AWS::ELB.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        alb.load_balancers.map { |load_balancer| load_balancer.name }
      end

      def metric_list
        [
          ["ActiveConnectionCount", "Average", "Count", 0],
          ["ClientTLSNegotiationErrorCount", "Sum", "Count", 0],
          ["ConsumedLBCapacityUnits", "Sum", "Count", 0],
          ["HealthyHostCount", "Maximum", "Count", 0],
          ["HTTPCode_ELB_4XX", "Sum", "Count", 0],
          ["HTTPCode_ELB_5XX", "Sum", "Count", 0],
          ["HTTPCode_Target_2XX_Count", "Sum", "Count", 0],
          ["HTTPCode_Target_3XX_Count", "Sum", "Count", 0],
          ["HTTPCode_Target_4XX_Count", "Sum", "Count", 0],
          ["HTTPCode_Target_5XX_Count", "Sum", "Count", 0],
          ["NewConnectionCount", "Sum", "Count", 0],
          ["ProcessedBytes", "Average", "Bytes", 0],
          ["RequestCount", "Sum", "Count", 0],
          ["RejectedConnectionCount", "Sum", "Count", 0],
          ["TargetConnectionErrorCount", "Sum", "Count", 0],
          ["TargetResponseTime", "Average", "Milliseconds", 0],
          ["TargetTLSNegotiationErrorCount", "Sum", "Count", 0],
          ["UnHealthyHostCount", "Maximum", "Count", 0],
        ]
      end

      def collect
        data_points = []
        load_balancers.each do |load_balancer_name|
          metric_list.each do |(metric_name, statistic, unit, default_value)|
            data_point = get_data_point(
              :namespace     => "AWS/ApplicationELB",
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
