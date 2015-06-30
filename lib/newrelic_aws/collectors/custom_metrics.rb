module NewRelicAWS
  module Collectors
    class CUSTOM_METRICS < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
      end

      def metric_list
        [
          ["Recognizer Production","RecognizerRecordingQueueSize", "Average", "Count", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerRecordingQueueLatency", "Average", "Milliseconds", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerRecordingProcessingLatency", "Average", "Milliseconds", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerUploadFailure", "Sum", "Count", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerServerFreeMemory", "Average", "Kilobytes", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerServicesFailure", "Average", "Count", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerServicesSuccess", "Average", "Count", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerRecordingInitialize", "Average", "Count", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerRecordingSuccess", "Average", "Count", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerConnections", "Average", "Count", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerUploadProcessingLatency", "Average", "Milliseconds", "Recognizer", "DeploymentEnvironment", "prod"],
          ["Recognizer Production","RecognizerUploadSuccess", "Average", "Count", "Recognizer", "DeploymentEnvironment", "prod"]
        ]
      end

      def collect
        data_points = []
        metric_list.each do |(app_name, metric_name, statistic, unit, namespace, dimension_name, dimension_value)|
          period = 60
          time_offset = 60
          data_point = get_data_point(
            :namespace   => namespace,
            :metric_name => metric_name,
            :statistic   => statistic,
            :unit        => unit,
            :dimension   => {
              :name  => dimension_name,
              :value => dimension_value
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