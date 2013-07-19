module NewRelicAWS
  module Collectors
    class SWF < Base
      def domains
        swf = AWS::SimpleWorkflow.new(
          :access_key_id => @aws_access_key,
          :secret_access_key => @aws_secret_key,
          :region => @aws_region
        )

        domain = swf.domains
        swf.domains.map { |domain|

          #TODO delete this if you want other domains
          if domain.name == "Scraper"
            
          openCount = 0
          completedCount = 0
          failedCount = 0
          timed_outCount = 0
          running_workflow_runtime_total = 0
          workflow_start_time = (Time.now.utc-(60)).iso8601
          
          executions = domain.workflow_executions.started_after(workflow_start_time)
          totalCount = executions.count.to_i

          completeExecutions = executions.with_status("COMPLETED")
          completeExecutions.each do |execution|
            completedCount += 1
            starttime = execution.started_at
            endtime = execution.closed_at
            running_workflow_runtime_total += (endtime - starttime)
          end

          avgRuntime = 0
          if completedCount != 0
            avgRuntime = (running_workflow_runtime_total/completedCount)
          end

          failedCount = executions.count({:status => "FAILED"}).to_i
          timed_outCount = executions.count({:status => "TIMED_OUT"}).to_i
          openCount = totalCount - (completedCount + failedCount + timed_outCount)

          putMetric("SWF/#{domain.name}", "Pending_Activity_Tasks_SSU", "Count", domain.activity_tasks.count("PRODUCTION_SSU_SCRAPE_TASKS").to_i, "environment", "production")
          putMetric("SWF/#{domain.name}", "Pending_Activity_Tasks_PRIORITY", "Count", domain.activity_tasks.count("PRODUCTION_PRIORITY_SCRAPE_TASKS").to_i, "environment", "production")
          putMetric("SWF/#{domain.name}", "Decision_Tasks_PRIORITY", "Count", domain.decision_tasks.count("PRODUCTION_PRIORITY_SCRAPE_TASKS").to_i, "environment", "production")
          putMetric("SWF/#{domain.name}", "open_workflow_executions", "Count", openCount, "environment", "production")
          putMetric("SWF/#{domain.name}", "completed_workflow_executions", "Count", completedCount, "environment", "production")
          putMetric("SWF/#{domain.name}", "failed_workflow_executions", "Count", failedCount, "environment", "production")
          putMetric("SWF/#{domain.name}", "timed_out_workflow_executions", "Count", timed_outCount, "environment", "production")
          putMetric("SWF/#{domain.name}", "average_workflow_completion_time", "Seconds", avgRuntime, "environment", "production")

        #TODO delete this if you want other domains
        end
        }
        swf.domains
      end

      def metric_list
        [
          ["Pending_Activity_Tasks_SSU", "Sum", "Count"],
          ["Pending_Activity_Tasks_PRIORITY", "Sum", "Count"],
          ["Decision_Tasks_PRIORITY", "Sum", "Count"],
          ["open_workflow_executions", "Sum", "Count"],
          ["completed_workflow_executions", "Sum", "Count"],
          ["failed_workflow_executions", "Sum", "Count"],
          ["timed_out_workflow_executions" , "Sum", "Count"],
          ["average_workflow_completion_time", "Average", "Seconds"]
        ]
      end

      def collect
        data_points = []
        domains.each do |domain|
          if domain.name == "Scraper"
            metric_list.each do |(metric_name, statistic, unit)|
              data_point = get_data_point(
                :namespace   => "SWF/Scraper",
                :metric_name => metric_name,
                :statistic   => statistic,
                :unit        => unit,
                :dimension   => {
                  :name => "environment",
                  :value => "production"
                },
                :period => 60,
                :start_time => (Time.now.utc-(120)).iso8601,
                :component => "production"
              )
              unless data_point.nil?
                data_points << data_point
              end
            end
          end
        end
        data_points
      end
    end
  end
end

def putMetric(namespace, metric_name, unit, value, dimensions_name, dimensions_value)
   
   AWS.config(
            :access_key_id => 'AKIAJHQDWCQVYHKXZMSA',
            :secret_access_key => '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'
            )

          @cw ||= AWS::CloudWatch.new
              @cw.put_metric_data(
                  :namespace => namespace,
                  :metric_data => [
                      { :metric_name => metric_name, :unit => unit, :value => value, :dimensions => [{:name => dimensions_name, :value => dimensions_value}] },
                  ]
              )
end