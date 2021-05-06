require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'lustre' do

 # Wait for the script to decide it has enough interfaces
 describe command("sleep 120") do
   its(:exit_status) { should eq 0 }
 end

 describe command("lctl list_nids") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /tcp$/ }
 end

 describe file('/usr/local/sbin/lustre-tune') do
  its(:content) { should match /turning LRU off on/ }
 end

 describe file('/usr/local/sbin/mountLustre') do
  its(:content) { should match /Starting lustre filesystems/ }
 end

 describe file('/etc/systemd/system/lustre-tune.service') do
  its(:content) { should match /Description=/ }
 end

 describe file('/etc/systemd/system/mountLustre.service') do
  its(:content) { should match /Description=/ }
 end

 describe file('/etc/modprobe.d/lustreclient.conf') do
  it { should exist }
 end
end
