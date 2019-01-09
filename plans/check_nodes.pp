plan puppet_health_check::check_nodes(
  TargetSpec  $nodes,
) {

  get_targets($nodes).each |$node| {
    $r = run_task('puppet_health_check::agent_health', $node, '_catch_errors' => true)
    $r.each |$result| {
     $response = $result.value
      if $response['noop'] {
        $noop = run_task('puppet_health_check::fix_noop', $node, '_catch_errors' => true)
        case $noop {
          Error['puppet_health_check/debug'] : {
            notice("${noop.message}")
          }
          Error : { fail_plan($noop) } }
        }
                    }
        $noop.each | $noop_result | {
          if $noop_result.ok {
            notice("Fixed noop on ${node}")
          } else {
            notice("${node} errored with a message: ${noop_result.value}")
          }
        }
      }
      if $result.ok {
        notice("${node} returned a value: ${result.value}")
      } else {
        notice("${node} errored with a message: ${result.value}")
      }
    }
  }
}
