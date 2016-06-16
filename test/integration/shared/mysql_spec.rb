require 'serverspec'

# Required by serverspec
set :backend, :exec

#horrible patch to the String class to allow numeric comparison
# class String
#   def be_greater_than other
#     to_i > other.to_i rescue false
#   end
# end


describe 'Test ID: 1' do
	describe service('mysql') do
	  it { should be_enabled }
	end
end

describe 'Test ID: 2 & Test ID:3' do
	describe command('mysqladmin -u root version') do
	  its(:stdout) { should contain('5.6').after('Distrib') }
	end
end

describe 'Test ID: 4' do
	describe user('mysql') do
	  it { should exist }
	end
end

describe 'Test ID: 5' do
	describe port(3306) do
	  it { should be_listening }
	end
end

describe 'Test ID: 7' do
	describe command('/etc/init.d/mysql restart') do
	  its(:exit_status) { should eq 0 }
	end
end

describe 'Test ID: 8' do
	describe file('/var/lib/mysql/') do
	  it { should be_directory }
	end
end

#mysql/8
# describe command('du -sh /var/lib/mysql | cut -d M -f 1')
#   its(:stdout) { should be_greater_than "100" }
# end

