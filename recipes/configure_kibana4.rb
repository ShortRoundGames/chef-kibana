
# Run Kibana 4
script "run_kibana" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    #{node['kibana']['installdir']}/current/server/bin/kibana.sh -p 80
  EOH
end
