require 'spec_helper_acceptance'

describe file('/etc/puppetlabs/puppet/puppet.conf') do
  its(:content) { is_expected.not_to match %r{noop = true} }
  run_shell('puppet config set --agent noop=true')
  its(:content) { is_expected.to match %r{noop = true} }
end
