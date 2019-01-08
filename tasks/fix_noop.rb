#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'time'
require 'json'

confprint = 'puppet config print --render-as json'
output, stderr, status = Open3.capture3(confprint)
if status != 0
  puts stderr
  exit 1
end

json = {}

params = JSON.parse(STDIN.read)
config = JSON.parse(output)

target_state = if params['_target_state']
                 true
               else
                 false
               end

current_state = config['noop']

if target_state != current_state
  _output, stderr, _status = Open3.capture3('puppet config set noop ' + target_state)
  if stderr =~ /.*/
    result = stderr
    json['noop_fix'] = 'error encountered'
  else
    result = 'noop value was ' + current_state + ' it is now ' + target_state
  end
else
  result = 'No action required'
end

if json.empty?
  exit_code = 0
  state = 'clean'
else
  exit_code = 1
  state = 'issues found'
end

json['state']    = state
json['certname'] = config['certname']
json['output']   = result
json['date']     = Time.now.iso8601
puts JSON.dump(json)
exit exit_code
