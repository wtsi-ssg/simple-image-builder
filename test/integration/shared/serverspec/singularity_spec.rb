require 'serverspec'

# Required by serverspec
set :backend, :exec

describe command('singularity help') do
  its(:stdout) { should match /Linux container platform optimized for High Performance Computing/ }
  its(:exit_status) { should eq 0 }
end

describe command('git clone https://github.com/GodloveD/lolcow-installer') do
  its(:exit_status) { should eq 0 }
end


describe command('singularity build lolcow lolcow-installer/Singularity') do
  its(:exit_status) { should eq 0 }
end

describe command('singularity run lolcow') do
  its(:stdout) { should match /\(oo\)/ }
  its(:exit_status) { should eq 0 }
end
