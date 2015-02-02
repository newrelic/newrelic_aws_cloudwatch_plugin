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
          @cluster_ids = clusters.map { |c| [c[:cluster_identifier], c[:number_of_nodes]] }
        rescue => e
          NewRelic::PlatformLogger.error("Unexpected error: " + e.inspect)
          NewRelic::PlatformLogger.debug("Backtrace: " + e.backtrace.join("\n "))
          return []
        end
      end

      def metric_list
        [
          ["CPUUtilization",              "Average", "Percent",      [:node, :cluster]],
          ["DatabaseConnections",         "Average", "Count",        [:cluster]],
          ["HealthStatus",                "Average", "Count",        [:cluster]],
          ["MaintenanceMode",             "Average", "Count",        [:cluster]],
          ["NetworkReceiveThroughput",    "Average", "Bytes/Second", [:node, :cluster]],
          ["NetworkTransmitThroughput",   "Average", "Bytes/Second", [:node, :cluster]],
          ["PercentageDiskSpaceUsed",     "Average", "Percent",      [:node, :cluster]],
          ["ReadIOPS",                    "Average", "Count/Second", [:node]],
          ["ReadLatency",                 "Average", "Seconds",      [:node]],
          ["ReadThroughput",              "Average", "Bytes/Second", [:node]],
          ["WriteIOPS",                   "Average", "Count/Second", [:node]],
          ["WriteLatency",                "Average", "Seconds",      [:node]],
          ["WriteThroughput",             "Average", "Bytes/Second", [:node]]
        ]
      end

      def node_metric?(ty)
        ty.include?(:node)
      end

      def cluster_metric?(ty)
        ty.include?(:cluster)
      end

      def node_data_point(metric_name, statistic, unit, node_id, cluster_id)
        get_data_point(
          :namespace      => "AWS/Redshift",
          :metric_name    => metric_name,
          :statistic      => statistic,
          :unit           => unit,
          :dimensions     => [
            {
              :name  => "ClusterIdentifier",
              :value => cluster_id
            },
            {
              :name  => "NodeID",
              :value => node_id
            }
          ]
        )
      end

      def cluster_data_point(metric_name, statistic, unit, cluster_id)
        get_data_point(
          :namespace      => "AWS/Redshift",
          :metric_name    => metric_name,
          :statistic      => statistic,
          :unit           => unit,
          :dimension      => {
            :name  => "ClusterIdentifier",
            :value => cluster_id
          }
        )
      end

      def log_data_point(metric_name, statistic, unit, data_point)
        NewRelic::PlatformLogger.debug(
          "metric_name: #{metric_name}, statistic: #{statistic}, unit: #{unit}, response: #{data_point.inspect}"
        )
      end

      def collect
        data_points = []
        clusters.each do |cluster_id, num_nodes|
          metric_list.each do |(metric_name, statistic, unit, type)|
            if node_metric?(type)
              (num_nodes+1).times do |i|
                node_id = i==num_nodes ? "Leader" : "Compute-#{i}"
                data_point = node_data_point(metric_name, statistic, unit, node_id, cluster_id)
                log_data_point(metric_name, statistic, unit, data_point)
                data_points << data_point unless data_point.nil?
              end
            end
            if cluster_metric?(type)
              data_point = cluster_data_point(metric_name, statistic, unit, cluster_id)
              log_data_point(metric_name, statistic, unit, data_point)
              data_points << data_point unless data_point.nil?
            end
          end
        end
        data_points
      end
    end
  end
end
