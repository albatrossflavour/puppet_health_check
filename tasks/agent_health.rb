#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'time'
require 'json'
require 'socket'

confprint = 'puppet config print --render-as json'
output, stderr, status = Open3.capture3(confprint)
if status != 0
  puts stderr
  exit 1
end

json = {}
json['issues'] = {}

params = JSON.parse(STDIN.read)
config = JSON.parse(output)

noop_run = if params['_noop']
             true
           else
             false
           end

puppet_interval = if params['interval'].is_a? Integer
                    params['interval'].to_i
                  else
                    1800
                  end

certname     = config['certname']
pm_port      = config['masterport'].to_i
noop         = config['noop']
lock_file    = config['agent_disabled_lockfile']
interval     = config['runinterval']
statedir     = config['statedir']
puppetmaster = config['server']
ca_server    = config['ca_server']
requestdir   = config['requestdir']

if noop == true
  json['issues']['noop'] = 'noop set to true'
end

if File.file?(lock_file)
  json['issues']['lock_file'] = 'agent disabled lockfile found'
end

if !File.file?(requestdir + '/' + certname + '.pem') && (certname != ca_server)
  json['issues']['signed_cert'] = 'Signed cert not found'
end

if interval.to_i != puppet_interval
  json['issues']['runinterval'] = 'not set to ' + puppet_interval.to_s
end

run_time = 0
last_run = statedir + '/last_run_summary.yaml'
if File.file?(last_run)
  last_run_contents = File.open(last_run, 'r').read
  last_run_contents.each_line do |line|
    matchdata = line.match(/^\s*last_run: ([0-9]*)/)
    next unless matchdata
    run_time = matchdata[1]
  end
  now = Time.new.to_i
  if (now - interval.to_i) > run_time.to_i
    json['issues']['last_run'] = 'Last run too long ago'
  end
  failcount = 0
  last_run_contents = File.open(last_run, 'r').read
  last_run_contents.each_line do |line|
    matchdata = line.match(/.*(fail.*: [1-9]|skipped.*: [1-9])/)
    next unless matchdata
    failcount += 1
  end
  if failcount > 0
    json['issues']['failures'] = 'Last run had failures'
  end
else
  json['issues']['last_run'] = 'Cannot locate file : ' + last_run
end

report = statedir + '/last_run_report.yaml'
failcount = 0
if File.file?(report)
  report_contents = File.open(report, 'r').read
  report_contents.each_line do |line|
    matchdata = line.match(/status: failed/)
    next unless matchdata
    failcount += 1
  end
  if failcount > 0
    json['issues']['catalog'] = 'Catalog failed to compile'
  end
end

statuscount = 0
output, _stderr, _status = Open3.capture3('puppet resource service puppet')
output.split("\n").each do |line|
  matchdata = line.match(/\s+(ensure.*running|enable.*true)/)
  next unless matchdata
  statuscount += 1
end
if statuscount != 2
  json['issues']['service'] = 'Puppet service not configured to run'
end

begin
  TCPSocket.new(puppetmaster, pm_port)
rescue
  json['issues']['port'] = 'Port ' + pm_port.to_s + ' on ' + puppetmaster + ' not reachable'
end

if json['issues'].empty?
  exit_code = 0
  state = 'clean'
else
  exit_code = 0
  state = 'issues found'
end

json['state']    = state
json['certname'] = certname
json['date']     = Time.now.iso8601
json['noop_run'] = noop_run
puts JSON.dump(json)
exit exit_code
