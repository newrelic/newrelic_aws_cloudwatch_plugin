module NewRelicAWS
  module Collectors
    class EC2 < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
        @ec2 = AWS::EC2.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        @tags = options[:tags]
        @component_name_option = options[:component_name_option]
        @s3_bucket = options[:s3_bucket]
        @component_names = options[:component_name_asset]
      end
      
      def define_component_names 
        if @component_name_option
          return get_metric_options(@s3_bucket,@component_names)
        end
      end

      def instances
        if @tags
          tagged_instances
        else
          @ec2.instances
        end
      end

      def tagged_instances
        instances = @ec2.instances.tagged(@tags).to_a
        instances.concat(@ec2.instances.tagged('Name', 'name').tagged_values(@tags).to_a)
        instances
      end

      def metric_list
        [
          ["CPUUtilization", "Maximum", "Percent", "AWS/EC2"],
          ["DiskReadOps", "Average", "Count", "AWS/EC2"],
          ["DiskWriteOps", "Average", "Count", "AWS/EC2"],
          ["DiskWriteBytes" , "Average", "Bytes", "AWS/EC2"],
          ["NetworkIn", "Average", "Bytes", "AWS/EC2"],
          ["NetworkOut", "Average", "Bytes", "AWS/EC2"],
          ["MemoryUtilization", "Maximum", "Percent", "System/Linux"]
        ]
      end

      def collect
        common_names = define_component_names
        data_points = []
        app_name = nil
        instances.each do |instance|
          detailed = instance.monitoring == :enabled
          name_tag = instance.tags.detect { |tag| tag.first =~ /^name$/i }
          if name_tag.nil? then
            next
          end
          unless common_names.nil?
            JSON.parse(common_names).each do |common_name|
              case name_tag.to_s
              when /#{common_name['condition']}/
                app_name = common_name['app_name']
                break
              else
                next
              end
            end
            if app_name.nil? then
              next
            end
          end
          metric_list.each do |(metric_name, statistic, unit, namespace)|
            period = detailed ? 60 : 300
            time_offset = detailed ? 60 : 600
            time_offset += @cloudwatch_delay
            data_point = get_data_point(
              :namespace   => namespace,
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimension   => {
                :name  => "InstanceId",
                :value => instance.id
              },
              :period => period,
              :start_time => (Time.now.utc - (time_offset + period)).iso8601,
              :end_time => (Time.now.utc - time_offset).iso8601,
              :component_name => name_tag.nil? ? instance.id : app_name.nil? ? "#{name_tag.last} (#{instance.id})" : "#{app_name}"
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
