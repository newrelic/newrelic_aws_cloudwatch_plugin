module NewRelicAWS
  module Collectors
    class ECR < EC
      def clusters
        super('redis')
      end

      def metric_list
        [
          ["CPUUtilization", "Average", "Percent"],
          ["SwapUsage", "Average", "Bytes"],
          ["FreeableMemory", "Average", "Bytes"],
          ["NetworkBytesIn", "Average", "Bytes", 0],
          ["NetworkBytesOut", "Average", "Bytes", 0],
          ["CurrConnections", "Average", "Count"],
          ["Evictions", "Sum", "Count"],
          ["Reclaimed", "Sum", "Count"],
          ["NewConnections", "Sum", "Count"],
          ["BytesUsedForCache", "Average", "Bytes"],
          ["CacheHits", "Sum", "Count"],
          ["CacheMisses", "Sum", "Count"],
          ["GetTypeCmds", "Sum", "Count", 0],
          ["SetTypeCmds", "Sum", "Count", 0],
          ["KeyBasedCmds", "Sum", "Count", 0],
          ["StringBasedCmds", "Sum", "Count"],
          ["HashBasedCmds", "Sum", "Count", 0],
          ["ListBasedCmds", "Sum", "Count", 0],
          ["SetBasedCmds", "Sum", "Count", 0],
          ["SortedSetBasedCmds", "Sum", "Count", 0],
          ["CurrItems", "Average", "Count"]
        ]
      end

    end
  end
end