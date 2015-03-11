
# Run Kibana 4
script "run_kibana" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    killall node
    sleep 5
    #{node['kibana']['installdir']}/current/server/bin/kibana & disown
  EOH
end
