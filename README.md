
# agent_health_check


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with agent_health_check](#setup)
    * [What agent_health_check affects](#what-agent_health_check-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with agent_health_check](#beginning-with-agent_health_check)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

A set of tasks to carry out health checks on puppet infrastructure.  Includes things such as :

* Valiating the puppetmaster/compile masters are reachable from the agent
* The puppet agent is enabled and running
* The run interval is set to the desired value
* The last run was within the run interval
* If the catalog failed to compile
* If any errors were encountered on the last puppet run


## Setup

Providing you can run tasks, you should be ok

If your most recent release breaks compatibility or requires particular steps for upgrading, you might want to include an additional "Upgrading" section here.

### Beginning with agent_health_check

`puppet task show puppet_health_check::agent_health` should get you going, everything is driven through tasks which can be accessed from the command line or the PE console.  When you run the task, you'll see output like:

```bash
# puppet task run puppet_health_check::agent_health -q 'inventory[certname] {}'
Starting job ...
Note: The task will run only on permitted nodes.
New job ID: 487
Nodes: 4

Started on puppetmaster.example.com ...
Started on linode-centos-73.example.com ...
Started on win-3ebipmjenlq.example.coexample.com ...
Started on cd4pe.example.com ...
Finished on node cd4pe.example.com
  date : 2018-09-04T14:24:55+10:00
  state : clean
  certname : cd4pe.example.com
Finished on node puppetmaster.example.com
  date : 2018-09-04T14:24:55+10:00
  state : clean
  certname : puppetmaster.example.com
Finished on node linode-centos-73.example.com
  date : 2018-09-04T14:24:56+10:00
  state : clean
  certname : linode-centos-73.example.com
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

## Limitations

I'm sure there are many, but not found anything obvious yet

## Development

Fork, develop, submit a PR
