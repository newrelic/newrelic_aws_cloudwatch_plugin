## New Relic Amazon CloudWatch Plugin ##

### v3.3.1 - March 22, 2014 ###

**Features**

* Added new `ASG` plugin support for AutoScaling Groups (Brett Cave <brett@cave.za.net>)

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