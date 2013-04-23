require "aws-sdk"

module NewRelicAWS
  module Collectors
    class Base < Struct.new(:options); end
    class EC2 < Base; end
    class RDS < Base; end
  end
end
