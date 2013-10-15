module NewRelicAWS
  module Components
    class Collection
      attr_reader :guid
      def initialize(guid, version)
        @guid = guid
      end

      def report_metric(request, component, metric_name, unit, value)
        request.add_metric(component, "Component/#{metric_name}[#{unit}]", value)
      end
    end
  end
end
