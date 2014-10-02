node.set['nginx']['default_site_enabled'] = false

include_recipe "nginx"

template "#{node['nginx']['dir']}/conf.d/default.conf" do
  source 'nginx-default.erb'
  owner  'root'
  group  node['root_group']
  mode   '0644'
  notifies :reload, 'service[nginx]', :immediately
end

template "#{node['nginx']['dir']}/sites-available/test" do
  source 'nginx-site.erb'
  owner  'root'
  group  node['root_group']
  mode   '0644'
  notifies :reload, 'service[nginx]'
end

nginx_site 'test' do
  enable true
end

include_recipe "apache2"
include_recipe "apache2::mod_ssl"

directory "/srv/vhost_sample" do
  owner 'root'
  group 'wheel'
  mode 0755
  action :create
  recursive true
end

web_app "my_site" do
  server_name "my-site.localhost"
  server_aliases ["www.my-site.localhost"]
  docroot "/srv/vhost_sample"
end

apache_site '000-default' do
  enable false
end
