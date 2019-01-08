plan puppet_health_check::check_nodes(
  TargetSpec  $nodes,
) {

  get_targets($nodes).each |$node| {
    $r = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
    $r.each |$result| {
      $response = $result.value
      if $response['noop'] {
        notice('Noop set - fixing')
      }
      if $result.ok {
        notice("${node} returned a value: ${result.value}")
      } else {
        notice("${node} errored with a message: ${result.value}")
      }
    }
  }
}
