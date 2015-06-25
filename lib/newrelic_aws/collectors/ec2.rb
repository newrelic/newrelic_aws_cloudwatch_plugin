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
          ["CPUUtilization", "Average", "Percent"],
          ["DiskReadOps", "Average", "Count"],
          ["DiskWriteOps", "Average", "Count"],
          ["DiskWriteBytes" , "Average", "Bytes"],
          ["NetworkIn", "Average", "Bytes"],
          ["NetworkOut", "Average", "Bytes"]
        ]
      end

      def collect
        data_points = []
        instances.each do |instance|
          detailed = instance.monitoring == :enabled
          name_tag = instance.tags.detect { |tag| tag.first =~ /^name$/i }
          metric_list.each do |(metric_name, statistic, unit)|
            period = detailed ? 60 : 300
            time_offset = detailed ? 60 : 600
            time_offset += @cloudwatch_delay
            if name_tag.nil? then
              break
            end
            case name_tag.to_s
            when /ecsiteprod-*/
              app_name = "Production Website"
            when /bridgeprod-*/
              app_name = "Bridge Production"
            when /wowza-se-recognizer-prod-*/
              app_name = "Recognizer Production"
            when /reportcardprod-*/
              app_name = "Reportcard Production"
            when /tutorprod-*/
              app_name = "Tutor Production"
            when /postofficeprod-*/
              app_name = "PostOffice Production"
            when /metermanprod-*/
              app_name = "Meterman Production"
            when /infocusprod-*/
              app_name = "Cambridge Production"
            when /tallyhoprod-*/
              app_name = "Tallyho Production"
            when /thinnerprod-*/
              app_name = "Thinner Production"
            else
              break
            end
            data_point = get_data_point(
              :namespace   => "AWS/EC2",
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
              :component_name => name_tag.nil? ? instance.id : "#{app_name}"
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
