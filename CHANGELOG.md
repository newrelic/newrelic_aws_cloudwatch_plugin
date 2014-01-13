## New Relic AWS CloudWatch Plugin ##

### v3.3.0 - Unreleased ###

**Features**

* Added AWS tag filtering for EC2 and EBS instances
* Added new metrics to ELB: `BackendConnectionErrors`, `SurgeQueueLength`, and `SpilloverCount`

**Bug Fixes**

* Fixed detailed one minute monitoring for EC2 instances

### v3.2.1 - December 16, 2013 ###

**Features**

* Added `cloudwatch_delay` attribute to configure each service. See README for details
* Added AWS SDK debug logging at verbose log level 2 or higher

### v3.2.0 - November 6, 2013 ###

**Features**

* Upgraded AWS SDK to 1.24.0 for general improvements