require 'serverspec'

# Required by serverspec
set :backend, :exec

describe package('metricbeat') do
  it { should be_installed }
end

describe service('metricbeat-openstack-setup') do
  it { should be_running }
  it { should be_enabled }
end

#Check that the ssg-ci project id is in the output
describe command('cat /etc/metricbeat/metricbeat.yml') do
  its(:stdout) { should match /2773a12573d849f7a5d758f1fb7637e8/ }
end

describe command('metricbeat test output') do
  its(:exit_status) { should eq 0 }
end
