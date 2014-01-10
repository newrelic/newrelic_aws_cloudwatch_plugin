module NewRelicAWS
  module Collectors
    class Base
      def initialize(access_key, secret_key, region, options)
        @aws_access_key = access_key
        @aws_secret_key = secret_key
        @aws_region = region
        @cloudwatch = AWS::CloudWatch.new(
          :access_key_id     => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region            => @aws_region
        )
        @cloudwatch_delay = options[:cloudwatch_delay] || 60
      end

      def get_data_point(options)
        options[:period]     ||= 60
        options[:start_time] ||= (Time.now.utc - (@cloudwatch_delay * 2)).iso8601
        options[:end_time]   ||= (Time.now.utc - @cloudwatch_delay).iso8601
        options[:dimensions] ||= [options[:dimension]]
        NewRelic::PlatformLogger.info("Retrieving statistics: " + options.inspect)
        begin
          statistics = @cloudwatch.client.get_metric_statistics(
            :namespace   => options[:namespace],
            :metric_name => options[:metric_name],
            :unit        => options[:unit],
            :statistics  => [options[:statistic]],
            :period      => options[:period],
            :start_time  => options[:start_time],
            :end_time    => options[:end_time],
            :dimensions  => options[:dimensions]
          )
        rescue => error
          NewRelic::PlatformLogger.error("Unexpected error: " + error.message)
          NewRelic::PlatformLogger.debug("Backtrace: " + error.backtrace.join("\n "))
          raise error
        end
        NewRelic::PlatformLogger.info("Retrieved statistics: #{statistics.inspect}")
        point = statistics[:datapoints].last
        return if point.nil?
        component   = options[:component]
        component ||= options[:dimensions].map { |dimension| dimension[:value] }.join("/")
        statistic = options[:statistic].downcase.to_sym
        [component, options[:metric_name], point[:unit].downcase, point[statistic], point[:timestamp].to_i]
      end

      def collect
        []
      end
    end
  end
end
