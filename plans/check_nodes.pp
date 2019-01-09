plan puppet_health_check::check_nodes(
  TargetSpec  $nodes,
) {

  get_targets($nodes).each |$node| {
    $r = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
    $r.each |$result| {
     $response = $result.value
      if $response['noop'] {
        $noop = run_task('puppet_health_check::fix_noop', $node, '_catch_errors' => true)
        if $noop.ok {
          notice("${node} returned a value: ${noop}")
        } else {
          notice("${node} errored with a message: ${noop}")
        }
      }
      if $result.ok {
        info("${node} returned a value: ${result.value}")
      } else {
        info("${node} errored with a message: ${result.value}")
      }
    }
  }
}
