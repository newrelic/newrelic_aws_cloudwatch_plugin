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
        {
          "NumberOfMessagesSent"                  => "Count",
          "SentMessageSize"                       => "Bytes",
          "NumberOfMessagesReceived"              => "Count",
          "NumberOfEmptyReceives"                 => "Count",
          "NumberOfMessagesDeleted"               => "Count",
          "ApproximateNumberOfMessagesDelayed"    => "Count",
          "ApproximateNumberOfMessagesVisible"    => "Count",
          "ApproximateNumberOfMessagesNotVisible" => "Count"
        }
      end

      def collect
        data_points = []
        queue_urls.each do |url|
          metric_list.each do |metric_name, unit|
            data_point = get_data_point(
              :namespace   => "AWS/SQS",
              :metric_name => metric_name,
              :unit        => unit,
              :dimension   => {
                :name  => "QueueName",
                :value => url
              }
            )
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
