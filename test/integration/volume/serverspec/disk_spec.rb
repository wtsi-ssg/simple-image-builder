require 'serverspec'

# Required by serverspec
set :backend, :exec


# #horrible patch to the String class to allow numeric comparison
# class String
#   def be_greater_than other
#     to_i > other.to_i rescue false
#   end
# end




# #mysql/7
# describe command('du -sh /data1/mysql_server/mysql | cut -d M -f 1')
#   its(:stdout) { should be_greater_than "100" }
# end

#mysql/6
describe "Test ID 6:" do

	describe file('/data1') do
	  it { should be_mounted.with( :type => 'ext4' ) }
	end
	# describe file('/data1') do
	#   it { should be_mounted.with( :options => { :mode => 0755 } ) }
	# end
end

