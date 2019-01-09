plan puppet_health_check::check_nodes(
  TargetSpec $nodes,
) {

  without_default_logging() || {
    $first_check = run_task('puppet_health_check::agent_health', $nodes, '_catch_errors' => true)
    $first_check.each | $result | {
      $node = $result.target.name
      unless $result.ok {
        notice "${node} health check failed"
        next()
      }

      if $result.value['state'] == 'clean' {
        notice "${node} heath check passed"
        next()
      } else {
        notice "${node} some checks failed, trying to remediate"
      }

      $response = $result.value

      if $response['noop'] {
        $noop = run_task('puppet_health_check::fix_noop', $node, '_catch_errors' => true)
        if $noop.ok {
          notice "${node} noop fixed"
        } else {
          notice "${node} could not fix noop"
        }
      }

      $second_check = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
      $second_check.each | $result | {
        notice "${node} ${result.value}"
      }
    }
  }
}
