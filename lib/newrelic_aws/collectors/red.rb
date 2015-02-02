module NewRelicAWS
  module Collectors
    class RED < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
      end

      def clusters
        return @clusters_ids if @clusters_ids
        red = AWS::Redshift.new(
          :access_key_id     => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region            => @aws_region
        )
        begin
          clusters = red.client.describe_clusters[:clusters]
          @cluster_ids = clusters.map { |c| c[:cluster_identifier] }
        rescue => e
          NewRelic::PlatformLogger.error("Unexpected error: " + e.inspect)
          NewRelic::PlatformLogger.debug("Backtrace: " + e.backtrace.join("\n "))
          return []
        end
      end

      def metric_list
        [
          ["CPUUtilization", "Average", "Percent"],
          ["DatabaseConnections", "Average", "Count"],
          ["HealthStatus", "Average", "Count"],
          ["MaintenanceMode", "Average", "Count"],
          ["NetworkReceiveThroughput", "Average", "Bytes/Second"],
          ["NetworkTransmitThroughput", "Average", "Bytes/Second"],
          ["PercentageDiskSpaceUsed", "Average", "Percent"],
          ["ReadIOPS", "Average", "Count/Second"],
          ["ReadLatency", "Average", "Seconds"],
          ["ReadThroughput", "Average", "Bytes/Second"],
          ["WriteIOPS", "Average", "Count/Second"],
          ["WriteLatency", "Average", "Seconds"],
          ["WriteThroughput", "Average", "Bytes/Second"]
        ]
      end

      def collect
        data_points = []
        clusters.each do |cluster_id|
          metric_list.each do |(metric_name, statistic, unit)|
            data_point = get_data_point(
              :namespace   => "AWS/Redshift",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "ClusterIdentifier",
                :value => cluster_id
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
