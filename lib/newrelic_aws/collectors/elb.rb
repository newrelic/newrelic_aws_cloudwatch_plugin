module NewRelicAWS
  module Collectors
    class ELB < Base
      def load_balancers
        @elb = AWS::ELB.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )
        @elb.load_balancers.map { |load_balancer| load_balancer.name }
      end

      def metric_list
        [
          ["Latency", "Average", "Seconds"],
          ["RequestCount", "Sum", "Count", 0],
          ["HealthyHostCount", "Maximum", "Count", 0],
          ["UnHealthyHostCount", "Maximum", "Count", 0],
          ["HTTPCode_ELB_4XX", "Sum", "Count", 0],
          ["HTTPCode_ELB_5XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_2XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_3XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_4XX", "Sum", "Count", 0],
          ["HTTPCode_Backend_5XX", "Sum", "Count", 0],
          ["BackendConnectionErrors", "Sum", "Count", 0],
          ["SurgeQueueLength", "Maximum", "Count", 0],
          ["SpilloverCount", "Sum", "Count", 0]
        ]
      end

      def elb_component_name(elb_name)
        begin
          response = @elb.client.describe_tags( :load_balancer_names => [elb_name] )
          name_tag = response[:tag_descriptions].first[:tags].find { |tag| tag[:key] == 'Name' }
          elb_name = name_tag.nil? ? elb_name : name_tag[:value]
          return elb_name
        rescue => error
            NewRelic::PlatformLogger.error("Unexpected error: " + error.message)
            NewRelic::PlatformLogger.debug("Backtrace: " + error.backtrace.join("\n "))
          raise error
        end
      end

      def collect
        data_points = []
        load_balancers.each do |load_balancer_name|
          tag_name = elb_component_name(load_balancer_name)
          if tag_name.nil? then
            break
          end
          case tag_name.to_s
          when /ecsiteprod-*/
            component_name = "Production Website"
          when /bridgeprod-*/
            component_name = "Bridge Production"
          when /wowza-se-recognizer-prod-*/
            component_name = "Recognizer Production"
          when /reportcardprod-*/
            component_name = "Reportcard Production"
          when /tutorprod-*/
            component_name = "Tutor Production"
          when /postofficeprod-*/
            component_name = "PostOffice Production"
          when /metermanprod-*/
            component_name = "Meterman Production"
          when /infocusprod-*/
            component_name = "Cambridge Production"
          when /tallyhoprod-*/
            component_name = "Tallyho Production"
          when /thinnerprod-*/
            component_name = "Thinner Production"
          when /prod-recognizer-elb-*/
            component_name = "Recognizer Production"
          else
            component_name = load_balancer_name
            break
          end
          metric_list.each do |(metric_name, statistic, unit, default_value)|
            data_point = get_data_point(
              :namespace     => "AWS/ELB",
              :metric_name   => metric_name,
              :statistic     => statistic,
              :unit          => unit,
              :default_value => default_value,
              :dimension     => {
                :name  => "LoadBalancerName",
                :value => load_balancer_name
              },
              :component_name => component_name
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
