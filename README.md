
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

`puppet task show puppet_health_check::agent_health` should get you going

## Usage

All driven through tasks, either from the CLI, the console or via the API

## Limitations

I'm sure there are many, but not found anything obvious yet

## Development

Fork, develop, submit a PR
