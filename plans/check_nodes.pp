plan puppet_health_check::check_nodes(
  TargetSpec  $nodes,
) {

  get_targets($nodes).each |$node| {
    $recheck = false
    $r = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
    $r.each |$result| {
     $response = $result.value
      if $response['noop'] {
        $noop = run_task('puppet_health_check::fix_noop', $node, '_catch_errors' => true)
        if $noop.ok {
          info("${node} returned a value: ${noop}")
        } else {
          notice("${node} errored with a message: ${noop}")
        }
        $recheck = true
      }
      if $recheck {
        $r = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
        $r.each |$result| {
          if $result.ok {
            info("${node} returned a value: ${result.value}")
          } else {
            notice("${node} errored with a message: ${result.value}")
          }
        }
      } else {
        if $result.ok {
          info("${node} returned a value: ${result.value}")
        } else {
          notice("${node} errored with a message: ${result.value}")
        }
      }
    }
  }
}
