plan puppet_health_check::check_nodes(
  TargetSpec $nodes,
) {

  # Return codes
  # 0   : Clean
  # 1   : Health check couldn't run
  # 3   : Issue found but fixed
  # 4   : Issue found but automated fix failed
  # 100 : Issues remaining at the end of the check

  without_default_logging() || {
    $first_check = run_task('puppet_health_check::agent_health', $nodes, '_catch_errors' => true)
    $first_check.each | $result | {
      $node = $result.target.name
      # Return error for those that couldn't run the health check
      unless $result.ok {
        notice "${node},1,health check failed"
        next()
      }

      # Return clean for those that don't have any issues
      if $result.value['state'] == 'clean' {
        notice "${node},0,heath check passed"
        next()
      }

      $response = $result.value

      # Fix the noop issues
      if $response['issues']['noop'] {
        $noop = run_task('puppet_health_check::fix_noop', $node, '_catch_errors' => true)
        if $noop.ok {
          notice "${node},3,noop fixed"
        } else {
          notice "${node},4,could not fix noop"
        }
      }

      # Fix the lockfile issues
      if $response['issues']['lock_file'] {
        $lockfile = run_task('puppet_health_check::fix_lockfile', $node, '_catch_errors' => true)
        if $lockfile.ok {
          notice "${node},3,lockfile fixed"
        } else {
          notice "${node},4,could not fix lockfile"
        }
      }

      # Fix the runinterval issues
      if $response['issues']['runinterval'] {
        $runinterval = run_task('puppet_health_check::fix_runinterval', $node, '_catch_errors' => true)
        if $runinterval.ok {
          notice "${node},3,runinterval fixed"
        } else {
          notice "${node},4,could not fix runinterval"
        }
      }

      # Fix last_run issue
      if $response['issues']['last_run'] {
        $last_run = run_command('puppet agent -t', $node, '_catch_errors' => true)
        if $last_run.ok {
          notice "${node},3,puppet agent run"
        } else {
          notice "${node},4,puppet agent failed"
        }
      }

      # Fix service not running issue
      if $response['issues']['service'] {
        $service = run_task('service', $node, name => 'puppet', action => enable, '_catch_errors' => true)
        if $service.ok {
          notice "${node},3,puppet service enabled"
        } else {
          notice "${node},4,puppet not able to be enabled"
        }

        $restart = run_task('service', $node, name => 'puppet', action => restart, '_catch_errors' => true)
        if $restart.ok {
          notice "${node},3,puppet service restarted"
        } else {
          notice "${node},4,puppet not able to be restarted"
        }
      }

      # Do the second run to validate that things have been fixed
      $second_check = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
      $second_check.each | $result | {
        $result.value['issues'].each | $issue | {
          # Return any residual issues
          notice "${node},100,${issue[1]}"
        }
      }
    }
  }
}
