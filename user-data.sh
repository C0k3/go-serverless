#!/bin/bash

# get value of REPO_URL tag on the instance
# this is the repo path that stores pipelines.gocd.yaml file
instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
pipelineRepo=$(aws --region us-east-1 ec2 describe-tags --filters "Name=resource-id,Values=${instanceId}" | grep -2 REPO_URL | grep Value | tr -d ' ' | cut -f2-3 -d: | tr -d '"' | tr -d ',')
echo "
[gocd]
name     = GoCD YUM Repository
baseurl  = https://download.go.cd
enabled  = 1
gpgcheck = 1
gpgkey   = https://download.go.cd/GOCD-GPG-KEY.asc
" | tee /etc/yum.repos.d/gocd.repo
yum update -y
yum remove -y java-1.7.0-openjdk
yum install -y go-server httpd-tools git java-1.8.0-openjdk
service go-server stop
echo "getting slack plugin"
curl -L https://github.com/ashwanthkumar/gocd-slack-build-notifier/releases/download/v1.4.0-RC10/gocd-slack-notifier-1.4.0-RC10.jar -o /var/lib/go-server/plugins/external/gocd-slack-notifier-1.4.0-RC10.jar
echo "getting yaml pipeline plugin"
curl -L https://github.com/tomzo/gocd-yaml-config-plugin/releases/download/0.4.0/yaml-config-plugin-0.4.0.jar -o /var/lib/go-server/plugins/external/yaml-config-plugin-0.4.0.jar
echo "getting script-executor plugin"
curl -L https://github.com/gocd-contrib/script-executor-task/releases/download/0.3/script-executor-0.3.0.jar -o /var/lib/go-server/plugins/external/script-executor-0.3.0.jar
htpasswd -bcs /etc/go/htpasswd $GO_USER $GO_PW
git clone https://github.com/tj/n
cd n
make install
cd ..
rm -rf n
/usr/local/bin/n stable
/usr/local/bin/npm install lodash co-sleep co co-parallel co-request aws-sdk js-yaml forever http-server stanza serverless -g

echo '
[credential]
        helper = !aws codecommit credential-helper $@
        UseHttpPath = true
' | tee /etc/gitconfig

echo -e "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<cruise xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xsi:noNamespaceSchemaLocation=\"cruise-config.xsd\" schemaVersion=\"81\">
  <server artifactsdir=\"artifacts\" agentAutoRegisterKey=\"112d2806f8bf4342a6f8041b5532dfa3\"
     commandRepositoryLocation=\"default\" serverId=\"c8beb214-61b9-4f1c-b4d9-f32942ed93b5\">
     <security>
       <passwordFile path=\"/etc/go/htpasswd\" />
     </security> 
  </server>
  <config-repos>
    <config-repo plugin=\"yaml.config.plugin\">
      <git url=\"${pipelineRepo}\" branch=\"master\" />
    </config-repo>
  </config-repos>
</cruise>" | tee /etc/go/cruise-config.xml
echo "export PATH=/usr/local/bin:node_modules/.bin:\$PATH" | tee /etc/profile.d/go.sh
chown go:go /etc/go/cruise-config.xml
chown go:go /etc/go/htpasswd
yum install -y go-agent
service go-server start
service go-agent start
