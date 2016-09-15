require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Test ID: 1' do
	describe service('mysql') do
	  it { should be_enabled }
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

describe 'mysql client configured' do
    describe command('mysql -u root --password=supersecret -e "show processlist"') do
      its(:stdout) { should contain('show processlist') }
    end
end

describe 'Test ID: 2 & Test ID:3' do
        describe command('mysqladmin -u root --password=supersecret version') do
          its(:stdout) { should contain('5.6').after('Server version') }
        end
end
