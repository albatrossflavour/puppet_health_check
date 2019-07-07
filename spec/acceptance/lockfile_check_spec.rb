require 'spec_helper_acceptance'

describe 'test lockfile workflow' do
  context 'create lockfile' do
    it do
      run_shell('mkdir -p /opt/puppetlabs/puppet/cache/state')
      run_shell('touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock')
      expect(file('/opt/puppetlabs/puppet/cache/state/agent_disabled.lock')).to be_file
    end
  end
  context 'remote lockfile' do
    it do
      run_bolt_task('puppet_health_check::fix_lockfile')
      expect(file('/opt/puppetlabs/puppet/cache/state/agent_disabled.lock')).not_to be_file
    end
  end
end
