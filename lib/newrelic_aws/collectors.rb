require "aws-sdk"

module NewRelicAWS
  module Collectors
    class Base
      def initialize(options={})
        @cloudwatch = AWS::CloudWatch.new(
          :access_key_id => options[:access_key],
          :secret_access_key => options[:secret_key],
          :region => options[:region]
        )
      end

      def collect!; end
    end

    class EC2 < Base; end
    class RDS < Base; end
  end
end
