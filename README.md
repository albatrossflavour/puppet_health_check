# puppet_health_check


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with puppet_health_check](#setup)
    * [What puppet_health_check affects](#what-puppet_health_check-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_health_check](#beginning-with-puppet_health_check)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

A set of tasks (and plan) to carry out health checks on puppet agents.  Includes things such as :

* Validating the puppetmaster/compile masters are reachable from the agent
* The puppet agent is enabled and running
* The run interval is set to the desired value
* The last run was within the run interval
* If the catalog failed to compile
* If any errors were encountered on the last puppet run


## Setup

Providing you can run tasks, you should be ok.  The tasks and plan have been tested on Linux (centos, ubuntu, redhat, and debian) and various Windows versions.  It **SHOULD** work on anything with a puppet agent capable of running tasks.

### Beginning with puppet_health_check

`puppet task show puppet_health_check::agent_health` should get you going, everything is driven through tasks and plans which can be accessed from the command line or the PE console.  When you run the task, you'll see output like:

```bash
# puppet task run puppet_health_check::agent_health -q 'inventory[certname] {}'
Starting job ...
Note: The task will run only on permitted nodes.
New job ID: 487
Nodes: 4

Started on puppetmaster.example.com ...
Started on client01.example.com ...
Started on win-3ebipmjenlq.example.com ...
Started on client02.example.com ...
Finished on node client02.example.com
  date : 2018-09-04T14:24:55+10:00
  state : clean
  certname : client02.example.com
Finished on node puppetmaster.example.com
  date : 2018-09-04T14:24:55+10:00
  state : clean
  certname : puppetmaster.example.com
Finished on node client01.example.com
  date : 2018-09-04T14:24:56+10:00
  state : clean
  certname : client01.example.com
Failed on win-3ebipmjenlq.example.com
  Error: Task finished with exit-code 1
  date : 2018-09-04T14:26:28+10:00
  state : issues found
  service : Puppet service not configured to run
  certname : win-3ebipmjenlq.example.com

Job completed. 4/4 nodes succeeded.
Duration: 5 sec
```

## Usage

All driven through tasks, either from the CLI, the console or via the API

The health check task will check the following things :

* Is the agent running?
* Is the agent enabled?
* Is agent noop set?
* Is the agent lockfile present?
* Is the run interval set correctly?
* Is a signed certificate present?
* Was the last agent run within the right timeframe?
* Were there failures in the last run?
* Did the catalog compilation fail?
* Can the agent reach a (compile)master on the right port?

A `bolt plan` exists which automates the end to end check and resolution of (most) issue.

The plan executes the health check, picks up failures which it can deal with (see below), tries to resolve them, re-checks the failed nodes and then reports on the results.

* Start the agent
* Enable the agent
* Reset noop mode
* Reset run interval
* Remove lockfile
* Trigger an agent run

### Example

```
# bolt plan --modulepath '/etc/puppetlabs/code/environments/production/modules/' run puppet_health_check::fix_nodes  --query='inventory[certname] {}' --transport pcp --format json
Starting: plan puppet_health_check::fix_nodes
client01.example.com,0,heath check passed
puppetmaster.example.com,0,heath check passed
client02.example.com,3,runinterval fixed
client02.example.com,4,puppet agent failed
Finished: plan puppet_health_check::fix_nodes in 6.14 sec
```

The exit codes from the plan are :

*  0   : Clean
*  1   : Health check couldn't run
*  3   : Issue found but fixed
*  4   : Issue found but automated fix failed
*  100 : Issues remaining at the end of the check

## Limitations

I'm sure there are many, but not found anything obvious yet

## Development

Fork, develop, submit a PR
