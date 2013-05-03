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
        {
          "Latency"              => "Seconds",
          "RequestCount"         => "Count",
          "HealthyHostCount"     => "Count",
          "UnHealthyHostCount"   => "Count",
          "HTTPCode_ELB_4XX"     => "Count",
          "HTTPCode_ELB_5XX"     => "Count",
          "HTTPCode_Backend_2XX" => "Count",
          "HTTPCode_Backend_3XX" => "Count",
          "HTTPCode_Backend_4XX" => "Count",
          "HTTPCode_Backend_5XX" => "Count"
        }
      end

      def collect
        data_points = []
        load_balancers.each do |load_balancer_name|
          metric_list.each do |metric_name, unit|
            data_point = get_data_point(
              :namespace   => "AWS/ELB",
              :metric_name => metric_name,
              :unit        => unit,
              :dimension   => {
                :name  => "LoadBalancerName",
                :value => load_balancer_name
              }
            )
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
