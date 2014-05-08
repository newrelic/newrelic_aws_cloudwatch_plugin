module NewRelicAWS
  module Collectors
    class SQS < Base
      def queue_urls
        sqs = AWS::SQS.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        sqs.queues.map { |queue| queue.url }
      end

      def metric_list
        [
          ["NumberOfMessagesSent", "Sum", "Count"],
          ["SentMessageSize", "Average", "Bytes"],
          ["NumberOfMessagesReceived", "Sum", "Count"],
          ["NumberOfEmptyReceives", "Sum", "Count"],
          ["NumberOfMessagesDeleted", "Sum", "Count"],
          ["ApproximateNumberOfMessagesDelayed", "Average", "Count"],
          ["ApproximateNumberOfMessagesVisible", "Average", "Count"],
          ["ApproximateNumberOfMessagesNotVisible", "Average", "Count"]
        ]
      end

      def collect
        data_points = []
        queue_urls.each do |url|
          metric_list.each do |(metric_name, statistic, unit)|
            period = 300
            time_offset = 600 + @cloudwatch_delay
            data_point = get_data_point(
              :namespace   => "AWS/SQS",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "QueueName",
                :value => url.split("/").last
              },
              :period => period,
              :start_time => (Time.now.utc - (time_offset + period)).iso8601,
              :end_time => (Time.now.utc - time_offset).iso8601
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
