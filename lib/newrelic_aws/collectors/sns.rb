module NewRelicAWS
  module Collectors
    class SNS < Base
      def topic_names
        sns = AWS::SNS.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        sns.topics.map { |topic| topic.name }
      end

      def metric_list
        [
          ["NumberOfMessagesPublished", "Sum", "Count"],
          ["PublishSize", "Average", "Bytes"],
          ["NumberOfNotificationsDelivered" , "Sum", "Count"],
          ["NumberOfNotificationsFailed", "Sum", "Count"]
        ]
      end

      def collect
        data_points = []
        topic_names.each do |topic_name|
          metric_list.each do |(metric_name, statistic, unit)|
            period = 300
            time_offset = 600 + @cloudwatch_delay
            data_point = get_data_point(
              :namespace   => "AWS/SNS",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "TopicName",
                :value => topic_name
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
