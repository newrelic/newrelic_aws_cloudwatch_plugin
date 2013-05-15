# New Relic AWS

This tool provides the metric collection agents for the following New Relic plugins:

- EC2
- EBS
- ELB
- RDS
- SQS
- SNS
- ElastiCache

Overview versions of the plugins above are also available.

## Dependencies
- A single t1.micro EC2 instance (in any region)
- Ruby (>= 1.8.7)
- Rubygems (>= 1.3.7)
- Bundler `gem install bundler`

## Install
1. Download the latest tagged version from `https://github.com/newrelic-platform/newrelic_aws_cloudwatch_extension/tags`
2. Extract to the location you want to run the plugin from
3. Run `cp config/newrelic_plugin.yml.example config/newrelic_plugin.yml`
4. Edit `config/newrelic_plugin.yml`
5. Run `bundle install`
6. Run `bundle exec ./bin/newrelic_aws`

## AMI
This collection of plugins is also available as an Amazon Machine Image (AMI) named `newrelic_aws`, making it easier to begin collecting metrics.

The AMI takes the contents of `config/newrelic_plugin.yml` as user-data, which is configured when creating the EC2 instance.
Once the instance is running with valid user-data, no further action is required.
To change the configuration, terminate the current instance and create another.

To access this AMI via the AWS EC2 console and launch an instance in your own AWS account, follow these steps:
1. Log in to your AWS account
2. Copy your AWS account number and paste into an email to mei@newrelic.com, CC'ing cooper@newrelic.com
3. Mei will enable sharing of this currently-private AMI to your AWS account
4. Once Mei notifies you that you can access the AMI, visit this URL `https://console.aws.amazon.com/ec2/home?region=us-west-2#launchAmi=ami-2f60f61f`

## Notes

- CloudWatch detailed monitoring is recommended, please enable it when available.
- Chart x-axis (time) is off by 60 seconds, this is due to CloudWatch's lag & lack of New Relic backfill (end time) support.
- Latest data point is used to fill gaps in low resolution metrics.
- Can use services like Upstart, Systemd, Runit, and Monit to manage the process.
