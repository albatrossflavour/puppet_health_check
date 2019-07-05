require 'spec_helper_acceptance'

describe 'health_check module' do
  context 'base class' do
    it do
      run_bolt_task('puppet_health_check::agent_health')
    end
  end
end

describe 'test and fix noop' do
  context 'base class' do
    it do
      run_shell('puppet config set --agent noop true')
      run_bolt_task('puppet_health_check::fix_noop')
    end
  end
end
