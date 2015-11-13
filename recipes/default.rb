#
# Cookbook Name:: kibana
# Recipe:: default
#
# Copyright 2013, John E. Vincent
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "git"
include_recipe "java"

es_instances = node[:opsworks][:layers][node['kibana']['es_role']][:instances]
es_hosts = es_instances.map{ |name, attrs| attrs['private_ip'] }

unless es_hosts.empty?
  node.set['kibana']['es_server'] = es_hosts.first
end

if node['kibana']['user'].empty?
  unless node['kibana']['webserver'].empty?
    webserver = node['kibana']['webserver']
    kibana_user = node[webserver]['user']
  else
    kibana_user = "nobody"
  end
else
  kibana_user = node['kibana']['user']
end

# Create all directories needed
directory node['kibana']['installdir'] do
  owner kibana_user
  mode "0755"
end

directory "#{node['kibana']['installdir']}/#{node['kibana']['version']}" do
  owner kibana_user
  mode "0755"
end

directory "#{node['kibana']['installdir']}/#{node['kibana']['version']}/src" do
  owner kibana_user
  mode "0755"
end

directory "#{node['kibana']['installdir']}/#{node['kibana']['version']}/src/server" do
  owner kibana_user
  mode "0755"
end

directory "#{node['kibana']['installdir']}/#{node['kibana']['version']}/src/server/config" do
  owner kibana_user
  mode "0755"
end

# Download server app from the web
remote_file "#{Chef::Config[:file_cache_path]}/kibana-#{node[:kibana][:version]}-linux-x64.tar.gz" do
#  source "https://download.elasticsearch.org/kibana/kibana/kibana-#{node[:kibana][:version]}-linux-x64.tar.gz"
  source "https://download.elastic.co/kibana/kibana/kibana-#{node[:kibana][:version]}-linux-x64.tar.gz"
end

# Install the server in the correct folder
bash "install_server" do
  user "root"
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
    tar -zxf kibana-#{node[:kibana][:version]}-linux-x64.tar.gz
    mv kibana-#{node[:kibana][:version]}-linux-x64/* #{node['kibana']['installdir']}/#{node['kibana']['version']}/src/server/
    rm -rf kibana-#{node[:kibana][:version]}-linux-x64
  EOH
end

# Move symlink to new directory
link "#{node['kibana']['installdir']}/current" do
  to "#{node['kibana']['installdir']}/#{node['kibana']['version']}/src"
end

template "#{node['kibana']['installdir']}/current/config.js" do
  source node['kibana']['config_template']
  cookbook node['kibana']['config_cookbook']
  mode "0750"
  user kibana_user
end

unless node['kibana']['webserver'].empty?
  include_recipe "kibana::#{node['kibana']['webserver']}"
end

# We need to put the ES server name inside config/kibana.yml
template "#{node['kibana']['installdir']}/current/server/config/kibana.yml" do
  source 'kibana.yml.erb'
  mode   '0644'
  owner  'root'
end

# We need to install a pill so we can run through bluepill
template "#{node['kibana']['installdir']}/kibana.pill" do
  source 'kibana.pill.erb'
  mode   '0644'
  owner  'root'
end
