include_recipe "ohai_plugins_test::vhosts"

node.override['wordpress']['parent_dir'] = '/srv/vhost_sample'
node.override['wordpress']['dir'] = '/srv/vhost_sample'

include_recipe "wordpress"

remote_file ::File.join(Chef::Config[:file_cache_path], "wordpress-cli-installer.sh") do
  source "https://raw.github.com/ryandub/wordpress-cli-installer/master/wordpress-cli-installer.sh"
  owner "root"
  group "root"
  mode 00700
  not_if {File.exists?(::File.join(Chef::Config[:file_cache_path], "wordpress-cli-installer.sh"))}
end

execute "configure_wordpress_wordpresstest.example.com" do
  cwd Chef::Config[:file_cache_path]
  command "sh wordpress-cli-installer.sh -b 'http://wordpresstest.example.com' -T 'WordPress Test' -e 'root@localhost' -u 'wptest' -p 'foobar22' /srv/vhost_sample"
  not_if "mysql -u #{node['wordpress']['db']['user']} -e \"select * from #{node['wordpress']['db']['name']}.#{node['wordpress']['db']['prefix']}options where option_name = 'siteurl';\" -p#{node['wordpress']['db']['pass']}"
end

hostsfile_entry '127.0.0.1' do
  hostname  'my-site.localhost'
  unique    true
end
