# New Relic AWS

This tool provides the metric collection agents for the following New Relic plugins:

- EC2
- EBS (Not Published)
- ELB (Not Published)
- RDS (Not Published)
- SQS (Not Published)
- SNS (Not Published)
- ElastiCache (Not Published)

Multi-region support.
Runs on a single machine.

## Dependencies
- Ruby
- Bundler `gem install bundler`

## Install
1. Download the latest tagged version from `https://github.com/newrelic-platform/newrelic_aws_cloudwatch_extension/tags`
2. Extract to the location you want to run the extention from
3. Run `cp config/newrelic_plugin.yml.example config/newrelic_plugin.yml`
4. Edit `config/newrelic_plugin.yml`
5. Run `bundle install`
6. Run `bundle exec ./bin/newrelic_aws`

## Notes

- Recommend using detailed monitoring (CloudWatch) when possible.
- Chart x-axis (time) is off by 60 seconds, due to CloudWatch's lag & lack of New Relic backfill (end time) support.
- Last data point is used to fill gaps in low resolution metrics.
