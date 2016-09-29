module NewRelicAWS
  module Collectors
    class ASG < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
        @asg = AWS::AutoScaling.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
      end

      def groups
        @asg.groups
      end

      def metric_list
        [
          ["CPUUtilization", "Average", "Percent"],
          ["DiskReadOps", "Sum", "Count"],
          ["DiskWriteOps", "Sum", "Count"],
          ["DiskWriteBytes" , "Sum", "Bytes"],
          ["NetworkIn", "Sum", "Bytes"],
          ["NetworkOut", "Sum", "Bytes"]
        ]
      end

      def collect
        data_points = []
        groups.each do |group|
          metric_list.each do |(metric_name, statistic, unit)|
            data_point = get_data_point(
              :namespace   => "AWS/EC2",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "AutoScalingGroupName",
                :value => group.name
              },
              :period => 60,
              :start_time => (Time.now.utc-120).iso8601,
              :component_name => group.name
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
