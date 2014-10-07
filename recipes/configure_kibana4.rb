
# Run Kibana 4
script "run_kibana" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    service nginx stop
    chmod 0755 #{node['kibana']['installdir']}/current/server/bin/kibana.sh
    #{node['kibana']['installdir']}/current/server/bin/kibana.sh -p 80
  EOH
end
