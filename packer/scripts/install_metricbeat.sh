#!/bin/bash
set -e
TYPE=$(python -mplatform | sed -e 's/.*focal.*/ubuntu/i' -e 's/.*centos.*/centos/i' -e 's/.*xenial.*/ubuntu/i'  -e 's/.*bionic.*/ubuntu/i' )
case ${TYPE} in
  ubuntu)
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    apt-get update
    apt-get install -y jq apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    apt-get update
    apt-get install -y metricbeat=7.10.2
    echo "metricbeat hold" | dpkg --set-selections
    ;;
  centos)
    sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    cat << EOF > /etc/yum.repos.d/elastic-7.x.repo
[elastic-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
    yum makecache
    yum install -y jq bind-utils yum-plugin-versionlock metricbeat-7.10.2
    yum versionlock metricbeat
    ;;
esac
cat <<EOT > /usr/local/sbin/metricbeat-setup
#!/bin/bash
METADATA=\$(curl -s 169.254.169.254/openstack/2018-08-27/meta_data.json)
PROJECT_ID=\$(jq '.project_id' <<<\${METADATA})
INSTANCE_ID=\$(jq '.uuid' <<<\${METADATA})
if host core-logstash.internal.sanger.ac.uk; then
  ELK_HOST="core-logstash.internal.sanger.ac.uk:5144"
else
  ELK_HOSTS=\$(host core-logstash.internal.sanger.ac.uk 172.18.255.1 | grep has | cut -d' ' -f4)
  for i in \$ELK_HOSTS; do
    if [ ELK_HOST -z ]; then
      ELK_HOST=\"\$i:5144\"
    else
      ELK_HOST=\$ELK_HOST,\"\$i:5144\"
    fi
  done
fi
cat << EOF > /etc/metricbeat/metricbeat.yml
metricbeat.config.modules:
  path: \\\${path.config}/modules.d/*.yml
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 1
  index.codec: best_compression
setup.kibana:
output.logstash:
  hosts: [\$ELK_HOST]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~
  - add_fields:
      target: openstack
      fields:
        project: \$PROJECT_ID
        instance: \$INSTANCE_ID
EOF
systemctl restart metricbeat
EOT
chmod 755 /usr/local/sbin/metricbeat-setup
cat << EOF > /etc/systemd/system/metricbeat-openstack-setup.service
[Unit]
Description=set up the config for metricbeat
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/local/sbin/metricbeat-setup

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable metricbeat-openstack-setup
systemctl start metricbeat-openstack-setup
cat /etc/metricbeat/metricbeat.yml
