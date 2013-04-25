module NewRelicAWS
  module Components
    class Collection
      def initialize(guid, version)
        @guid = guid
        @version = version
        options = NewRelic::Plugin::Config.config.newrelic
        @connection = NewRelic::Plugin::NewRelicConnection.new(options)
        @poll_cycle = options["poll"] || 60
        @collection = {}
      end

      def report_metric(component, metric_name, unit, value)
        @collection[component] ||= NewRelic::Plugin::NewRelicMessage.new(
          @connection,
          component,
          @guid,
          @version,
          @poll_cycle
        )
        @collection[component].add_stat_fullname(
          "Component/#{metric_name}[#{unit}]",
          1,
          value,
          :min => value,
          :max => value,
          :sum_of_squares => (value*value)
        )
      end

      def process
        @collection.each_value do |component|
          component.send_metrics
        end
        @collection = {}
      end
    end
  end
end
