module NewRelicAWS
  module Collectors
    class EC2 < Base
      def instance_ids
        ec2 = AWS::EC2.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        ec2.instances.map { |instance| instance.id }
      end

      def metric_list
        {
          "CPUUtilization" => "Percent",
          "DiskReadOps"    => "Count",
          "DiskWriteOps"   => "Count",
          "DiskWriteBytes" => "Bytes",
          "NetworkIn"      => "Bytes",
          "NetworkOut"     => "Bytes"
        }
      end

      def collect
        data_points = []
        instance_ids.each do |instance_id|
          metric_list.each do |metric_name, unit|
            data_point = get_data_point(
              :namespace   => "AWS/EC2",
              :metric_name => metric_name,
              :unit        => unit,
              :dimension   => {
                :name  => "InstanceId",
                :value => instance_id
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
