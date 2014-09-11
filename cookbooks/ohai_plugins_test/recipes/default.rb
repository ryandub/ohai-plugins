execute "use_ipv4" do
  command "echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6"
end

bash "git_clone_ohai_plugins_pull_request" do
  user 'root'
  cwd '/opt'
  code <<-EOH
  git clone #{node[:ohai_plugins_test][:repo]} /opt/ohai-plugins
  cd /opt/ohai-plugins
  git fetch origin pull/#{node[:ohai_plugins_test][:pr]}/head:prtest
  git checkout prtest
  EOH
  only_if { !node[:ohai_plugins_test][:pr].nil? }
end

git "/opt/ohai-plugins" do
  repository node[:ohai_plugins_test][:repo]
  reference node[:ohai_plugins_test][:ref]
  action :sync
  not_if do
    File.exist?('/home/vagrant') || !node[:ohai_plugins_test][:pr].nil?
  end
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

case node['platform_family']
when 'rhel'
  bash "make cronjob" do
    code <<-EOH
    echo -e "# THIS IS A COMMENT" > /var/spool/cron/root
    echo -e "MAILTO=root" >> /var/spool/cron/root
    echo -e "0 0 1 3 0 root echo hello" >> /var/spool/cron/root
    echo -e "@reboot echo hello" >> /var/spool/cron/root
    EOH
  end
when 'debian'
  bash "make cronjob" do
    code <<-EOH
    echo -e "# THIS IS A COMMENT" > /var/spool/cron/crontabs/root
    echo -e "MAILTO=root" >> /var/spool/cron/crontabs/root
    echo -e "0 0 1 3 0 root echo hello" >> /var/spool/cron/crontabs/root
    echo -e "@reboot echo hello" >> /var/spool/cron/crontabs/root
    EOH
  end
end

include_recipe "ohai_plugins_test::fail2ban"
