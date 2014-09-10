# Encoding: utf-8
include_recipe "ohai_plugins_test::vhosts"
include_recipe 'magento'

site = 'magento.example.com'

node.override['magento']['url'] = 'http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz'
node.override['magento']['dir'] = '/srv/magento'
node.override['apache']['config_file'] = "#{site}.conf"

remote_file ::File.join(Chef::Config[:file_cache_path] ,"magento.tar.gz") do
  source node['magento']['url']
  mode 0644
end

directory node['magento']['dir'] do
  recursive true
  owner "root"
  group "root"
  mode 00777
  action :create
end

execute 'untar-magento' do
  cwd node['magento']['dir']
  command <<-EOH
  tar --strip-components 1 -xzf \
  #{Chef::Config[:file_cache_path]}/magento.tar.gz
  EOH
end

web_app "magento" do
  server_name "magento.example.com"
  server_aliases ['magento.example.com']
  docroot '/srv/magento'
end


