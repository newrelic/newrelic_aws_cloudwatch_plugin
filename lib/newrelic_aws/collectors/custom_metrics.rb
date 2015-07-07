module NewRelicAWS
  module Collectors
    class CUSTOM_METRICS < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
      end

      def metric_list
        return get_metric_options(@s3_bucket,@custom_metrics)
      end

      def collect
        data_points = []
        custom_metrics = metric_list
        unless custom_metrics.nil?
          JSON.parse(custom_metrics).each do |(app_name, metric_name, statistic, unit, namespace, dimension_name, dimension_value)|
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
        end
        data_points
      end
    end
  end
end