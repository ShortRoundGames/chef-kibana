# NOTE: don't run this recipe if using Kibana 4

include_recipe 'htpasswd'
include_recipe 'nginx'

# add user "foo" with password "bar" to "/etc/nginx/htpasswd"
htpasswd "/etc/nginx/htpasswd" do
  user node['kibana']['web_user']
  password node['kibana']['web_password']
  notifies :reload, "service[nginx]"
end
