module NewRelicAWS
  module Collectors
    class DDB < Base
      def tables
        ddb = AWS::DynamoDB.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        ddb.tables.map { |table| table.name }
      end

      def metric_list
        {
          "UserErrors"                    => "Count",
          "SystemErrors"                  => "Count",
          "ThrottledRequests"             => "Count",
          "ProvisionedReadCapacityUnits"  => "Count",
          "ProvisionedWriteCapacityUnits" => "Count",
          "ConsumedReadCapacityUnits"     => "Count",
          "ConsumedWriteCapacityUnits"    => "Count",
          "ReturnedItemCount"             => "Count"
        }
      end

      def collect
        data_points = []
        tables.each do |table_name|
          metric_list.each do |metric_name, unit|
            data_point = get_data_point(
              :namespace   => "AWS/DynamoDB",
              :metric_name => metric_name,
              :unit        => unit,
              :dimension   => {
                :name  => "TableName",
                :value => table_name
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
