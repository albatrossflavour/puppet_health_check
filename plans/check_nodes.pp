plan puppet_health_check::check_nodes(
  TargetSpec  $nodes,
) {
  return run_task('puppet_health_check::agent_health', $nodes)
}
