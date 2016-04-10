include_recipe 'selinux::_common'
include_recipe 'python'
include_recipe 'python::pip'

package "epel-release" do
  action :install
end

#execute 'update system' do
##  command 'yum -y update'
#  command 'yum -y -x 'kernel*' update'
#end

bash "increase open file descriptors" do
  code <<-EOH
    ulimit -n 10000
    EOH
end

selinux_state "SELinux Disabled" do
  action :disabled
end

template "/etc/sysctl.conf" do
  path "/etc/sysctl.conf"
  source "sysctl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/selinux/config" do
  path "/etc/selinux/config"
  source "selinux.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/yum.repos.d/ambari.repo" do
  path "/etc/yum.repos.d/ambari.repo"
  source "ambari.repo.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/hosts" do
  path "/etc/hosts"
  source "hosts.erb"
  owner "root"
  group "root"
  mode 0644
end

file "/root/.ssh/authorized_keys" do
  action :delete
end

%w{curl unzip tar wget net-tools ntp python-pip}.each  do |list|
  package list
end

service "ntpd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start]
end

service "firewalld" do
  provider Chef::Provider::Service::Init::Redhat
  supports :status => true, :restart => true, :reload => true, :disable => true
  action :stop
end

directory "/root/.ssh" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

template "/root/.ssh/authorized_keys" do
  path "/root/.ssh/authorized_keys"
  source "authorized_keys.erb"
  owner "root"
  group "root"
end

template "/root/.ssh/config" do
  path "/root/.ssh/config"
  source "config_ssh.erb"
  owner "root"
  group "root"
end

template "/root/.ssh/id_rsa" do
  path "/root/.ssh/id_rsa"
  source "id_rsa.erb"
  owner "root"
  group "root"
  mode 0600
end

%w{ambari-agent }.each  do |list1|
  package list1
end


template "/etc/ambari-agent/conf/ambari-agent.ini" do
  source "ambari-agent.ini.erb"
  mode 0755
  user "root"
  group "root"
end

service 'ambari-agent' do
  action [:enable, :start]
end

