module NewRelicAWS
  module Collectors
    class KIN < Base
      def kinesis_streams
        kinesis = Aws::Kinesis::Client.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region,
          :http_proxy => @aws_proxy_uri
        )
        kinesis.list_streams.stream_names.map {|names|names}
      end

      def metric_list
        [
          ["IncomingBytes", "Sum", "Count", 0],
          ["IncomingRecords", "Sum", "Count", 0],
          ["GetRecords.Success", "Sum", "Count", 0],
          ["GetRecords.Latency", "Average", "Seconds", 0],
	  ["OutgoingBytes", "Sum", "Count", 0],
          ["OutgoingRecords", "Sum", "Count", 0],
          ["IteratorAgeMilliseconds", "Maximum", "Count", 0],
          ["ReadProvisionedThroughputExceeded", "Sum", "Count", 0],
          ["WriteProvisionedThroughputExceeded", "Sum", "Count", 0]
        ]
      end

      def collect
        data_points = []
        kinesis_streams.each do |stream_name|
          metric_list.each do |(metric_name, statistic, unit, default_value)|
            data_point = get_data_point(
              :namespace     => "AWS/Kinesis",
              :metric_name   => metric_name,
              :statistic     => statistic,
              :unit          => unit,
              :default_value => default_value,
              :dimension     => {
                :name  => "StreamName",
                :value => stream_name
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
