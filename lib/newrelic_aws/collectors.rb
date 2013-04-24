require "time"
require "aws-sdk"

module NewRelicAWS
  module Collectors
    class Base
      def initialize(options)
        @aws_access_key = options["access_key"]
        @aws_secret_key = options["secret_key"]
        @aws_region = options["region"] || "us-east-1"
        @cloudwatch = AWS::CloudWatch.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
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
        point_name = [options[:dimension][:value], options[:metric_name]].join("/")
        [point_name, point[:unit].downcase, point[:sum]]
      end

      def collect!; end
    end

    class EC2 < Base
      def instance_ids
        ec2 = AWS::EC2.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        ec2.instances.map { |instance| instance.id }
      end

      def metric_list
        {
          "CPUUtilization" => "Percent",
          "DiskReadOps"    => "Count",
          "DiskWriteOps"   => "Count",
          "DiskWriteBytes" => "Bytes",
          "NetworkIn"      => "Bytes",
          "NetworkOut"     => "Bytes"
        }
      end

      def collect!
        data_points = []
        instance_ids.each do |instance_id|
          metric_list.each do |metric_name, unit|
            data_point = get_data_point(
              :namespace   => "AWS/EC2",
              :metric_name => metric_name,
              :unit        => unit,
              :dimension  => {
                :name  => "InstanceId",
                :value => instance_id
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

    class RDS < Base; end
  end
end
