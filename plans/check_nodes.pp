plan puppet_health_check::check_nodes(
  TargetSpec $nodes,
  Boolean    $noop,
) {

  $plan_output = {}

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

      # Do we need to recheck the health after any task fixes?
      if $recheck {
        # Yes, we do need to
        $second_check = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
        if $second_check.ok {
          $plan_output[$node] = "${node} returned a value: ${result.value}"
        } else {
          $plan_output[$node] = "${node} errored with a message: ${result.value}"
        }
      } else {
        # No we don't, so just return the inital results
        if $result.ok {
          $plan_output[$node] = "${node} returned a value: ${result.value}"
        } else {
          $plan_output[$node] = "${node} errored with a message: ${result.value}"
        }
      }
    }
    return $plan_output
  }
}
