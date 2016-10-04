module NewRelicAWS
  module Collectors
    class EBS < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
        @ec2 = AWS::EC2.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        @tags = options[:tags]
      end

      def volumes
        if @tags
          tagged_volumes
        else
          @ec2.volumes.filter('status', 'in-use')
        end
      end

      def tagged_volumes
        volumes = @ec2.volumes.filter('status', 'in-use').tagged(@tags).to_a
        volumes.concat(@ec2.volumes.filter('status', 'in-use').tagged('Name', 'name').tagged_values(@tags).to_a)
        volumes
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
            period = detailed ? 60 : 300
            time_offset = detailed ? 60 : 600
            time_offset += @cloudwatch_delay
            data_point = get_data_point(
              :namespace   => "AWS/EBS",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "VolumeId",
                :value => volume.id
              },
              :period => period,
              :start_time => (Time.now.utc - (time_offset + period)).iso8601,
              :end_time => (Time.now.utc - time_offset).iso8601,
              :component_name => name_tag.nil? ? volume.id : "#{name_tag.last} (#{volume.id})"
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
