
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
  only_if { File.exist?("/home/vagrant") }
end

bash "make cronjob" do
  code <<-EOH
  echo -e "0 0 1 3 0 root echo hello" > /var/spool/cron/crontabs/root
  EOH
end

package 'fail2ban'

service 'fail2ban' do
  action :start
end

case node[:platform_family]
when 'rhel'
  logfile = '/var/log/messages'
when 'debian'
  logfile = '/var/log/fail2ban.log'
end

bash "add_fail2ban_lines" do
  code <<-EOH
  echo -e '2014-04-30 10:46:24,006 fail2ban.actions: WARNING [ssh] Ban 1.1.1.1\n2014-04-30 10:56:24,731 fail2ban.actions: WARNING [ssh] Unban 2.2.2.2\n' >> #{logfile}
  EOH
  only_if { File.exist?(logfile) }
end
