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
- Ruby (>= 1.9.2)
- Rubygems (>= 1.3.7)
- Bundler `gem install bundler`

## Install
1. Download the latest tagged version from [https://github.com/newrelic-platform/newrelic_aws_cloudwatch_extension/tags](https://github.com/newrelic-platform/newrelic_aws_cloudwatch_extension/tags)
2. Extract to the location you want to run the plugin from
3. Rename `config/template_newrelic_plugin.yml` to `config/newrelic_plugin.yml`
4. Add New Relic license key to `config/newrelic_plugin.yml`
5. Add your Amazon Web Services security credentials to `config/newrelic_plugin.yml`
6. Run `bundle install`
7. Run `bundle exec ./bin/newrelic_aws`

## AMI
This plugin will soon be available as an Amazon Machine Image (AMI) named newrelic_aws, making it easier to begin collecting metrics.

The AMI takes the contents of `config/newrelic_plugin.yml` as user-data, which is configured when creating the EC2 instance.
Once the instance is running with valid user-data, no further action is required.
To change the configuration, terminate the current instance and create another.

## Notes

- CloudWatch detailed monitoring is recommended, please enable it when available. (see *Using Amazon CloudWatch* section on http://aws.amazon.com/cloudwatch/)
- Chart x-axis (time) is off by 60 seconds, this is due to CloudWatch's lag & lack of New Relic backfill (end time) support.
- Latest data point is used to fill gaps in low resolution metrics.
- Can use services like Upstart, Systemd, Runit, and Monit to manage the process.

## Keep this process running
You can use services like these to manage this process.

- [Upstart](http://upstart.ubuntu.com/)
- [Systemd](http://www.freedesktop.org/wiki/Software/systemd/)
- [Runit](http://smarden.org/runit/)
- [Monit](http://mmonit.com/monit/)

## For support
Plugin support for troubleshooting assistance can be obtained by visiting [support.newrelic.com](https://support.newrelic.com)

