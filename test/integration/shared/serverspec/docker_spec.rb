require 'serverspec'

# Required by serverspec
set :backend, :exec


describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe command('docker run hello-world') do
  its(:stderr) { should match /Status: Downloaded newer image for hello-world:latest/ }
  its(:stdout) { should match /Hello from Docker!/ }
  its(:exit_status) { should eq 0 }
end

describe interface('docker0') do
  it { should exist }
  it { should be_up }
  it { should have_ipv4_address("192.168.3.3/24") }
end

describe command('timeout 60 curl -o /tmp/a https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-4.16-rc4.tar.gz') do
    its(:exit_status) { should eq 0 }
end

describe command('echo 963a757f2efaf80fc851c95fd141cc19  /tmp/a | md5sum -c') do
  its(:stdout) { should match /OK/ }
end




