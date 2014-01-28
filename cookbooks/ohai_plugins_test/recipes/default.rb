
git "/opt/ohai-plugins" do
  repository node[:ohai_plugins_test][:repo]
  reference node[:ohai_plugins_test][:ref]
  action :sync
end

git '/opt/ohai' do
  repository node[:ohai_plugins_test][:ohai][:repo]
  reference node[:ohai_plugins_test][:ohai][:ref]
  action :sync
end

bash "make_my_cnf" do
  code <<-EOH
  echo -e '[client]\nuser=root\npassword=#{node[:mysql][:server_root_password]}' > /root/.my.cnf
  EOH
end
