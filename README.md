# New Relic Amazon CloudWatch Plugin

This tool provides the metric collection agents for the following New Relic plugins:

- EC2
- EBS
- ELB
- RDS
- SQS
- SNS
- ElastiCache
  - Memcached
  - Redis

## Dependencies
- A single t1.micro EC2 instance (in any region)
- Ruby (>= 1.9.2)
- Rubygems (>= 1.3.7)
- Bundler `gem install bundler`
- Git

## Install

### Manual Installation
1. Download the latest tagged version from [https://github.com/newrelic-platform/newrelic_aws_cloudwatch_extension/tags](https://github.com/newrelic-platform/newrelic_aws_cloudwatch_extension/tags)
2. Extract to the location you want to run the plugin from
3. Rename `config/template_newrelic_plugin.yml` to `config/newrelic_plugin.yml`
4. Edit `config/newrelic_plugin.yml`
5. Run `bundle install`
6. Run `bundle exec ./bin/newrelic_aws` (or on Windows `bundle exec ruby bin\newrelic_aws`)

### Installation with Chef/Puppet

[Chef](http://www.getchef.com) and [Puppet](http://puppetlabs.com) are tools that automate software installation. The Amazon CloudWatch plugin has installation support for both:

  - [Chef Cookbook](http://community.opscode.com/cookbooks/newrelic_plugins)
  - [Puppet Module](https://forge.puppetlabs.com/newrelic/newrelic_plugins)

**Note:** For more information on using Chef and Puppet with New Relic, see the New Relic [docs](https://docs.newrelic.com/docs/plugins/plugin-installation-with-chef-and-puppet).

## Configuration

This plugin is configured through the `config/newrelic_plugin.yml` file. It requires:

- a New Relic license key that can be found at https://rpm.newrelic.com/extensions/com.newrelic.aws.ec2
- an AWS Access Key
- an AWS Secret Key

### Regions
The plugin can also be configured to query specific CloudWatch regions, e.g. `us-east-1` or `us-west-1`. By default the plugin will query all available regions.  

```
  regions:
    -
      us-east-1
    -
      us-east-2
    -
      us-west-1
```

### Amazon ElastiCache

Amazon ElastiCache supports both Memcached and Redis caching technologies. The Memcached agent is configured under the `ec` section, while the Redis agent is configured under the `ecr` section.

### Tag Filtering

Filtering instances by tags is supported for both `EC2` and `EBS`. Details on adding tags to instances is available in the [AWS documentation](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html).

A list of case-sensitive tags can be added to the yml configuration for `EC2` and `EBS` and only instances containing one or more of those tags will be monitored. This can reduce CloudWatch requests and costs.

Tagged instances will be monitored if they:

- have a tag with a matching key in the tag list (e.g. tagged with key `newrelic_monitored` and any value: `true`, `yes`, etc.)
- have a `Name` or `name` tag with a matching value in the tag list (e.g. tagged with key `Name` and value `prod_1_db`)

If there are no configured tags, all available instances will be monitored. This is the default behavior.

```
...
agents:
  ec2:
    enabled: true
    tags:
      - newrelic_monitored
      - prod_1_db
  ebs:
    enabled: true
    tags:
      - newrelic_monitored
```

### RDS Instance Filtering
When an IAM policy for rds:DescribeDBInstances has Resource restrictions, the rds-describe-db-instances call will fail when an allowed DBInstanceIdentifier is not specified.

If there are no configured instance_identifiers, all available instances will be monitored. This is the default behavior.

```
...
agents:
  rds:
    enabled: true
    instance_identifiers:
      - db1
      - db2
```

### CloudWatch Delay
As noted below, there is a default 60 second delay in reporting metrics from CloudWatch which adjusts the time window for queried data. This is due to CloudWatch metrics not being immediately available for querying as they may take some time to process. Unfortunately there is little that can be done from the plugin to address this, besides adjusting the time window for metric querying from CloudWatch. The configuration option `cloudwatch_delay` can be specified for each AWS agent to override the default 60 second delay.

```
...
agents:
  ec2:
    enabled: true
    cloudwatch_delay: 120
  ebs:
    enabled: true
...
```

####Affected Metrics

- `RDS/CPU Utilization` - If you see 0% CPU utilization, try increasing the `cloudwatch_delay` option for the AWS RDS agent.

## AMI
This plugin is also available as an Amazon Machine Image (AMI) via the AWS Marketplace. Learn more, then quickly install and configure the AMI here: https://aws.amazon.com/marketplace/pp/B00DMMUO0O/

The AMI takes the contents of `config/newrelic_plugin.yml` as user-data, which is configured when creating the EC2 instance. Once the instance is running with valid user-data, no further action is required. To change the configuration, terminate the current instance and create another.

If you like the AMI, please [leave a 5-star review](https://aws.amazon.com/marketplace/review/product-reviews/ref=dtl_pop_customer_reviews?ie=UTF8&asin=B00DMMUO0O) in the AWS Marketplace.

If you don't like the AMI, New Relic would appreciate that you do not leave a bad review on the AWS Marketplace. Instead, open a ticket with [New Relic Support](https://support.newrelic.com) and let us know what we could do better. We take your feedback very seriously - and by opening a ticket, we can notify you when we've addressed your feedback.

## IAM (AWS API Credentials)

Note: There is a fantastic blog post on this topic [here](http://www.paulsamiq.com/how-to-use-amazons-iam-with-new-relics-aws-plugin/) (screenshots).

This plugin requires AWS API credentials, using IAM is highly recommended, giving it read-only access to select services.

You will need to create a new IAM group, `NewRelicCloudWatch`, where the permissions will be defined. You will want to use a custom policy for the group, `NewRelicCloudWatch`, using the following JSON for the policy document.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:Describe*",
        "cloudwatch:Describe*",
        "cloudwatch:List*",
        "cloudwatch:Get*",
        "ec2:Describe*",
        "ec2:Get*",
        "ec2:ReportInstanceStatus",
        "elasticache:DescribeCacheClusters",
        "elasticloadbalancing:Describe*",
        "sqs:GetQueueAttributes",
        "sqs:ListQueues",
        "rds:DescribeDBInstances",
        "SNS:ListTopics"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

To get API credentials, a IAM user must be created, `NewRelicCloudWatch`. Be sure to save the user access key id and secret access key on creation. Add the user to the `NewRelicCloudWatch` IAM group. Use the IAM user API credentials in the plugin configuration file.

## Notes
- CloudWatch detailed monitoring is recommended, please enable it when available. (see *Using Amazon CloudWatch* section on http://aws.amazon.com/cloudwatch/)
- Chart x-axis (time) is off by 60 seconds, this is due to CloudWatch's lag in reporting metrics.
- Latest data point is used to fill gaps in low resolution metrics.

## Keep this process running
You can use services like these to manage this process.

- [Upstart](http://upstart.ubuntu.com/)
- [Systemd](http://www.freedesktop.org/wiki/Software/systemd/)
- [Runit](http://smarden.org/runit/)
- [Monit](http://mmonit.com/monit/)

## Or run it as a daemon
The provided daemon.rb file allows newrelic_aws to run as a daemon.

    chmod +x bin/daemon
    bundle exec bin/daemon start
    bundle exec bin/daemon stop

## For support
Plugin support and troubleshooting assistance can be obtained by visiting [support.newrelic.com](https://support.newrelic.com)

## Credits
The New Relic AWS plugin was originally authored by [Sean Porter](https://github.com/portertech) and the team at [Heavy Water Operations](http://hw-ops.com/). Subsequent updates and support are provided by [New Relic](http://newrelic.com/platform).
