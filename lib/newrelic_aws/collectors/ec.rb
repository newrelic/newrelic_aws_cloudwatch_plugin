module NewRelicAWS
  module Collectors
    class EC < Base
      def clusters
        ec = AWS::ElastiCache.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        clusters = ec.client.describe_cache_clusters(:show_cache_node_info => true)
        clusters[:cache_clusters].map do |cluster|
          {
            :id    => cluster[:cache_cluster_id],
            :nodes => cluster[:cache_nodes].map { |node| node[:cache_node_id] }
          }
        end
      end

      def metric_list
        [
          ["CPUUtilization", "Average", "Percent"],
          ["SwapUsage", "Average", "Bytes"],
          ["FreeableMemory", "Average", "Bytes"],
          ["NetworkBytesIn", "Average", "Bytes"],
          ["NetworkBytesOut", "Average", "Bytes"],
          ["BytesUsedForCacheItems", "Average", "Bytes"],
          ["BytesReadIntoMemcached", "Sum", "Bytes"],
          ["BytesWrittenOutFromMemcached", "Sum", "Bytes"],
          ["CasBadval", "Sum", "Count"],
          ["CasHits", "Sum", "Count"],
          ["CasMisses", "Sum", "Count"],
          ["CmdFlush", "Sum", "Count"],
          ["CmdGet", "Sum", "Count"],
          ["CmdSet", "Sum", "Count"],
          ["CurrConnections", "Average", "Count"],
          ["CurrItems", "Average", "Count"],
          ["DecrHits", "Sum", "Count"],
          ["DecrMisses", "Sum", "Count"],
          ["DeleteHits", "Sum", "Count"],
          ["DeleteMisses", "Sum", "Count"],
          ["Evictions", "Sum", "Count"],
          ["GetHits", "Sum", "Count"],
          ["GetMisses", "Sum", "Count"],
          ["IncrHits", "Sum", "Count"],
          ["IncrMisses", "Sum", "Count"],
          ["Reclaimed", "Sum", "Count"],
          ["BytesUsedForHash", "Average", "Bytes"],
          ["CmdConfigGet", "Sum", "Count"],
          ["CmdConfigSet", "Sum", "Count"],
          ["CmdTouch", "Sum", "Count"],
          ["CurrConfig", "Average", "Count"],
          ["EvictedUnfetched", "Sum", "Count"],
          ["ExpiredUnfetched", "Sum", "Count"],
          ["SlabsMoved", "Sum", "Count"],
          ["TouchHits", "Sum", "Count"],
          ["TouchMisses", "Sum", "Count"],
          ["NewConnections", "Sum", "Count"],
          ["NewItems", "Sum", "Count"],
          ["UnusedMemory", "Average", "Bytes"]
        ]
      end

      def collect
        data_points = []
        clusters.each do |cluster|
          metric_list.each do |(metric_name, statistic, unit)|
            cluster[:nodes].each do |node_id|
              data_point = get_data_point(
                :namespace   => "AWS/ElastiCache",
                :metric_name => metric_name,
                :statistic   => statistic,
                :unit        => unit,
                :dimensions  => [
                  {
                    :name  => "CacheClusterId",
                    :value => cluster[:id]
                  },
                  {
                    :name => "CacheNodeId",
                    :value => node_id
                  }
                ]
              )
              unless data_point.nil?
                data_points << data_point
              end
            end
          end
        end
        data_points
      end
    end
  end
end
