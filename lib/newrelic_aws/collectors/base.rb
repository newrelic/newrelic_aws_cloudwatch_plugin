module NewRelicAWS
  module Collectors
    class Base
      def initialize
        options = NewRelic::Plugin::Config.config.options["aws"]
        unless options.is_a?(Hash) &&
            options.has_key?("access_key") &&
            options.has_key?("secret_key")
          raise NewRelic::Plugin::BadConfig, "Missing or invalid AWS configuration."
        end
        @aws_access_key = options["access_key"]
        @aws_secret_key = options["secret_key"]
        @aws_region = options["region"] || "us-east-1"
        @cloudwatch = AWS::CloudWatch.new(
          :access_key_id     => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region            => @aws_region
        )
      end

      def get_data_point(options)
        options[:period]     ||= 60
        options[:start_time] ||= (Time.now.utc-120).iso8601
        options[:end_time]   ||= (Time.now.utc-60).iso8601
        statistics = @cloudwatch.client.get_metric_statistics(
          :namespace   => options[:namespace],
          :metric_name => options[:metric_name],
          :unit        => options[:unit],
          :statistics  => ["Sum"],
          :period      => options[:period],
          :start_time  => options[:start_time],
          :end_time    => options[:end_time],
          :dimensions  => [options[:dimension]]
        )
        point = statistics[:datapoints].last
        return if point.nil?
        [options[:dimension][:value], options[:metric_name], point[:unit].downcase, point[:sum]]
      end

      def collect
        []
      end
    end
  end
end
