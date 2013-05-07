module NewRelicAWS
  module Collectors
    class EBS < Base
      def volumes
        ec2 = AWS::EC2.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        ec2.volumes.select { |volume| volume.status == :in_use }
      end

      def metric_list
        {
          "VolumeReadBytes"            => "Bytes",
          "VolumeWriteBytes"           => "Bytes",
          "VolumeReadOps"              => "Count",
          "VolumeWriteOps"             => "Count",
          "VolumeTotalReadTime"        => "Seconds",
          "VolumeTotalWriteTime"       => "Seconds",
          "VolumeIdleTime"             => "Seconds",
          "VolumeQueueLength"          => "Count",
          "VolumeThroughputPercentage" => "Percent",
          "VolumeConsumedReadWriteOps" => "Count"
        }
      end

      def collect
        data_points = []
        volumes.each do |volume|
          detailed = !!volume.iops
          metric_list.each do |metric_name, unit|
            data_point = get_data_point(
              :namespace   => "AWS/EBS",
              :metric_name => metric_name,
              :unit        => unit,
              :dimension   => {
                :name  => "VolumeId",
                :value => volume.id
              },
              :period => detailed ? 60 : 300,
              :start_time => (Time.now.utc-(detailed ? 120 : 660)).iso8601
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
