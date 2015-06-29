module NewRelicAWS
  module Collectors
    class CUSTOM_METRICS < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
      end

      def metric_list
        [
          ["Recognizer Production","RecognizerRecordingQueueSize", "Maximum", "Count", "Recognizer"],
          ["Recognizer Production","RecognizerRecordingQueueLatency", "Maximum", "Milliseconds", "Recognizer"],
          ["Recognizer Production","RecognizerUploadFailure", "Sum", "Count", "Recognizer"],
          ["Recognizer Production","RecognizerServerFreeMemory", "Average", "Kilobytes", "Recognizer"],
          ["Recognizer Production","DiskSpaceUtilization", "Maximum", "Percent", "System/Linux"],
        ]
      end

      def collect
        data_points = []
        metric_list.each do |(app_name, metric_name, statistic, unit, namespace)|
          period = 60
          time_offset = 60
          data_point = get_data_point(
            :namespace   => namespace,
            :metric_name => metric_name,
            :statistic   => statistic,
            :unit        => unit,
            :dimension   => {
              :name  => "DeploymentEnvironment",
              :value => "prod"
            },
            :period => period,
            :start_time => (Time.now.utc - (time_offset + period)).iso8601,
            :end_time => (Time.now.utc - time_offset).iso8601,
            :component_name => "#{app_name}"
          )
          NewRelic::PlatformLogger.debug("metric_name: #{metric_name}, statistic: #{statistic}, unit: #{unit}, response: #{data_point.inspect}")
          unless data_point.nil?
            data_points << data_point
            puts data_point
          end
        end
        data_points
      end
    end
  end
end