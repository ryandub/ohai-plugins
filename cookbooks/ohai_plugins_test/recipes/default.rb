
git "/opt/ohai-plugins" do
  repository node[:ohai_plugins_test][:repo]
  reference node[:ohai_plugins_test][:ref]
  action :sync
  not_if { File.exists?("/home/vagrant") } # Use synced folder for local testing.
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

bash "make_vagrant_my_cnf" do
  code <<-EOH
  echo -e '[client]\nuser=root\npassword=#{node[:mysql][:server_root_password]}' > /home/vagrant/.my.cnf
  EOH
  only_if { File.exists?("/home/vagrant") }
end

cron_d 'echo-hello' do
  minute  0
  hour    0
  day     1
  month   3
  weekday 0
  command 'echo hello'
  user    'root'
end
