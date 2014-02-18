include_recipe "apache2"

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