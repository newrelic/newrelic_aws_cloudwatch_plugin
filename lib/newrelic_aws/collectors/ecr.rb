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
            ["NetworkBytesIn", "Average", "Bytes"],
            ["NetworkBytesOut", "Average", "Bytes"],
            ["CurrConnections", "Average", "Count"],
            ["Evictions", "Sum", "Count"],
            ["Reclaimed", "Sum", "Count"],
            ["NewConnections", "Sum", "Count"],
            ["BytesUsedForCache", "Average", "Bytes"],
            ["CacheHits", "Sum", "Count"],
            ["CacheMisses", "Sum", "Count"],
            ["GetTypeCmds", "Sum", "Count"],
            ["SetTypeCmds", "Sum", "Count"],
            ["KeyBasedCmds", "Sum", "Count"],
            ["StringBasedCmds", "Sum", "Count"],
            ["HashBasedCmds", "Sum", "Count"],
            ["ListBasedCmds", "Sum", "Count"],
            ["SetBasedCmds", "Sum", "Count"],
            ["SortedSetBasedCmds", "Sum", "Count"],
            ["CurrItems", "Average", "Count"]
        ]
      end

    end
  end
end
