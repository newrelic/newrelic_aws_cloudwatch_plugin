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
        [
          ["VolumeReadBytes", "Sum", "Bytes"],
          ["VolumeWriteBytes", "Sum", "Bytes"],
          ["VolumeReadOps", "Sum", "Count"],
          ["VolumeWriteOps", "Sum", "Count"],
          ["VolumeTotalReadTime", "Sum", "Seconds"],
          ["VolumeTotalWriteTime", "Sum", "Seconds"],
          ["VolumeIdleTime", "Sum", "Seconds"],
          ["VolumeQueueLength", "Sum", "Count"],
          ["VolumeThroughputPercentage", "Average", "Percent"],
          ["VolumeConsumedReadWriteOps", "Sum", "Count"]
        ]
      end

      def collect
        data_points = []
        volumes.each do |volume|
          detailed = !!volume.iops
          name_tag = volume.tags.detect { |tag| tag.first =~ /^name$/i }
          metric_list.each do |(metric_name, statistic, unit)|
            data_point = get_data_point(
              :namespace   => "AWS/EBS",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "VolumeId",
                :value => volume.id
              },
              :period => detailed ? 60 : 300,
              :start_time => (Time.now.utc-(detailed ? 120 : 660)).iso8601,
              :component => name_tag.nil? ? volume.id : "#{name_tag.last} (#{volume.id})"
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
