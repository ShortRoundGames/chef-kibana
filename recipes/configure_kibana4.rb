
# Restart Kibana 4
script "kill_old_kibana" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    killall node
    sleep 5
  EOH
end

execute "run-kibana" do
  command "nohup #{node['kibana']['installdir']}/current/server/bin/kibana &"
end
