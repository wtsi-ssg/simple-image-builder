#!/bin/bash

if [ "${SUDO_USER}" = "ubuntu" ] ; then
  apt-get install -y ruby rubygems-integration  ruby-dev
fi

if [ "${SUDO_USER}" = "centos" ] ; then
  yum install -y gcc centos-release-scl ruby-devel
  yum install -y rh-ruby25
  mkdir /tmp/wrap
  tee /tmp/wrap/ruby <<-EOF
#!/bin/bash
source /opt/rh/rh-ruby25/enable
ruby \$*
EOF
  tee /tmp/wrap/gem <<-EOF
#!/bin/bash
source /opt/rh/rh-ruby25/enable
if [ "\$1" = "install" ]; then
        gem \$* -i /tmp/verifier/gems
else
        gem \$*
fi
EOF
  chmod a+x /tmp/wrap/*
  ln -s /opt/rh/rh-ruby25/root/usr/lib64/libruby.so.2.5 /usr/lib64/libruby.so.2.5	#LD_LIBRARY_PATH is ignored fsr
  mkdir /opt/rh/rh-ruby25/root/usr/share/include
  ln -s /usr/include/ruby.h /opt/rh/rh-ruby25/root/usr/share/include/ruby.h
fi

#gem install rubygems-update
#gem update --system
