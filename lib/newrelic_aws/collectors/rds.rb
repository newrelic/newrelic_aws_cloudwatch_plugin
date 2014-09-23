module NewRelicAWS
  module Collectors
    class RDS < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
        @instance_ids = options[:instance_identifiers]
      end

      def instance_ids
        return @instance_ids if @instance_ids
        rds = AWS::RDS.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        rds.instances.map { |instance| instance.id }
      end

      def metric_list
        [
          ["BinLogDiskUsage", "Average", "Bytes"],
          ["CPUUtilization", "Average", "Percent"],
          ["DatabaseConnections", "Average", "Count"],
          ["DiskQueueDepth", "Average", "Count"],
          ["FreeableMemory", "Average", "Bytes"],
          ["FreeStorageSpace", "Average", "Bytes"],
          ["ReplicaLag", "Average", "Seconds"],
          ["SwapUsage", "Average", "Bytes"],
          ["ReadIOPS", "Average", "Count/Second"],
          ["WriteIOPS", "Average", "Count/Second"],
          ["ReadLatency", "Average", "Seconds"],
          ["WriteLatency", "Average", "Seconds"],
          ["ReadThroughput", "Average", "Bytes/Second"],
          ["WriteThroughput", "Average", "Bytes/Second"]
        ]
      end

      def collect
        data_points = []
        instance_ids.each do |instance_id|
          metric_list.each do |(metric_name, statistic, unit)|
            data_point = get_data_point(
              :namespace   => "AWS/RDS",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "DBInstanceIdentifier",
                :value => instance_id
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
