case node['platform_family']
when 'rhel'
    yum_repository 'epel' do
        description 'Extra Packages for Enterprise Linux'
        mirrorlist "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-#{node.platform_version.to_i}&arch=$basearch"
        gpgkey "http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{node.platform_version.to_i}"
        action :create
    end
    logfile = '/var/log/messages'
when 'debian'
    logfile = '/var/log/fail2ban.log'
end

package 'fail2ban'

service 'fail2ban' do
          action :start
end

bash "add_fail2ban_lines" do
          code <<-EOH
            echo -e '2014-04-30 10:46:24,006 fail2ban.actions: WARNING [ssh] Ban 1.1.1.1\n2014-04-30 10:56:24,731 fail2ban.actions: WARNING [ssh] Unban 1.1.1.1\n2014-04-30 11:46:24,006 fail2ban.actions: WARNING [ssh] Ban 2.2.2.2\n' >> #{logfile}
              EOH
                only_if { File.exist?(logfile) }
end
