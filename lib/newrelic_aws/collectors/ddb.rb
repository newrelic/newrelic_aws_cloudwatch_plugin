module NewRelicAWS
  module Collectors
    class DDB < Base
      def tables
        ddb = AWS::DynamoDB.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key
        )
        ddb.tables.map { |table| table.name }
      end

      def metric_list
        [
          ["UserErrors", "Sum", "Count"],
          ["SystemErrors", "Sum", "Count"],
          ["ThrottledRequests", "Sum", "Count"],
          ["ProvisionedReadCapacityUnits", "Sum", "Count"],
          ["ProvisionedWriteCapacityUnits", "Sum", "Count"],
          ["ConsumedReadCapacityUnits", "Sum", "Count"],
          ["ConsumedWriteCapacityUnits", "Sum", "Count"],
          ["ReturnedItemCount", "Sum", "Count"]
        ]
      end

      def collect
        data_points = []
        tables.each do |table_name|
          metric_list.each do |(metric_name, statistic, unit)|
            data_point = get_data_point(
              :namespace   => "AWS/DynamoDB",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "TableName",
                :value => table_name
              }
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
