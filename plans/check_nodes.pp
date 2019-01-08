plan puppet_health_check::check_nodes(
  TargetSpec  $nodes,
) {

  get_targets($nodes).each |$node| {
    $r = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
    $r.each |$result| {
      if $result.ok {
        notice("${node} returned a value: ${result.value}")
      } else {
        notice("${node} errored with a message: ${result.error.message}")
      }
    }
  }
}
