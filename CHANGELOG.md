## New Relic Amazon CloudWatch Plugin ##

### v3.3.5 - October 19, 2016 ###

**Changes**

* Support new namespace: AWS/ApplicationELB

### 3.3.4-olx.0.1 - November 3, 2016 ###

**Features**

* Added new `AWS ES` plugin support for AWS Elasticsearch (Dmytro Zavalkin <dmytro.zavalkin@olx.com>)

### v3.3.4 - July 21, 2016 ###

**Changes**

* Support new region: ap-south-1

### v3.3.3 - February 21, 2016 ###

**Changes**

* Update AWS SDK and support new regions: ap-northeast-2, eu-central-1

### v3.3.2 - September 25, 2014 ###

**Bug Fixes**

* Fixed a Ruby 1.8.7 bug that was introduced in v3.3.1

### v3.3.1 - September 23, 2014 ###

**Features**

* Added support for pulling AWS credentials from IAM Roles and Instance Profiles
* Added support for filtering RDS instances by instance identifiers

### v3.3.0a - March 22, 2014 ###

**Features**

* Added new `ASG` plugin support for AutoScaling Groups (Brett Cave <brett@cave.za.net>)

**Bug Fixes**

* Fixed cloudwatch_delay bug for EC2, EBS, SNS, and SQS where end_time was being set incorrectly

### v3.3.0 - January 22, 2014 ###

**Features**

* Added AWS tag filtering for EC2 and EBS instances
* Added new metrics to ELB: `BackendConnectionErrors`, `SurgeQueueLength`, and `SpilloverCount`
* Added new `ECR` plugin support for ElastiCache Redis

**Bug Fixes**

* Fixed detailed one minute monitoring for EC2 instances

**Changes**

* Overview dashboards have been deprecated

### v3.2.1 - December 16, 2013 ###

**Features**

* Added `cloudwatch_delay` attribute to configure each service. See README for details
* Added AWS SDK debug logging at verbose log level 2 or higher

### v3.2.0 - November 6, 2013 ###

**Features**

* Upgraded AWS SDK to 1.24.0 for general improvements
