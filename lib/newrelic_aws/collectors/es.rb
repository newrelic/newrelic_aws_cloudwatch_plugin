module NewRelicAWS
  module Collectors
    class ES < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
        @es = Aws::ElasticsearchService::Client.new(
            region: @aws_region,
            access_key_id: @aws_access_key,
            secret_access_key: @aws_secret_key
        )
        @sts = Aws::STS::Client.new(
            region: @aws_region,
            access_key_id: @aws_access_key,
            secret_access_key: @aws_secret_key
        )
      end

      def domains
        @es.list_domain_names.domain_names
      end

      def account_id
        @account_id ||= @sts.get_caller_identity.account
      end

      def metric_list
        [
          ["ClusterStatus.green", "Average", "Count", true],
          ["ClusterStatus.yellow", "Average", "Count", true],
          ["ClusterStatus.red", "Average", "Count", true],
          ["Nodes", "Average", "Count", true],
          ["SearchableDocuments", "Average", "Count", true],
          ["DeletedDocuments", "Average", "Count", true],
          ["CPUUtilization", "Minimum", "Percent", true],
          ["JVMMemoryPressure", "Maximum", "Percent", true],
          ["AutomatedSnapshotFailure", "Maximum", "Count", true],
          ["ClusterUsedSpace", "Maximum", "Megabytes", true],
          ["FreeStorageSpace", "Minimum", "Megabytes", true],

          ["DiskQueueDepth", "Average", "Count", false],
          ["ReadIOPS", "Sum", "Count/Second", false],
          ["WriteIOPS", "Sum", "Count/Second", false],
          ["ReadLatency", "Average", "Seconds", false],
          ["WriteLatency", "Average", "Seconds", false],
          ["ReadThroughput", "Sum", "Bytes/Second", false],
          ["WriteThroughput", "Sum", "Bytes/Second", false],
          ["CPUCreditBalance", "Minimum", "Count", false],
          ["ClusterIndexWritesBlocked", "Maximum", "Count", false]
        ]
      end

      def collect
        data_points = []
        domains.each do |domain|
          metric_list.each do |(metric_name, statistic, unit, detailed)|
            period = detailed ? 60 : 300
            time_offset = detailed ? 60 : 600
            time_offset += @cloudwatch_delay

            data_point = get_data_point(
              :namespace   => "AWS/ES",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => [
                {
                  :name  => "DomainName",
                  :value => domain.domain_name
                },
                {
                  :name  => "ClientId",
                  :value => account_id
                }
              ],
              :period => period,
              :start_time => (Time.now.utc - (time_offset + period)).iso8601,
              :end_time => (Time.now.utc - time_offset).iso8601,
              :component_name => domain.domain_name
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
