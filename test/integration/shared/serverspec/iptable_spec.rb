require 'serverspec'

# Required by serverspec
set :backend, :exec

describe iptables do
    it { should have_rule('-P INPUT ACCEPT' ) }
    it { should have_rule('-P FORWARD ACCEPT' ) }
    it { should have_rule('-P OUTPUT ACCEPT' ) }
    it { should_not have_rule('DROP' ) }
    it { should_not have_rule('REJECT' ) }
end
