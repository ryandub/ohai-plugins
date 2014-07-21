package 'postfix'

case node['platform_family']
when 'rhel', 'fedora'
  service 'sendmail' do
    action :nothing
  end

  execute 'set_postfix_to_default' do
    command '/usr/sbin/alternatives --set mta /usr/sbin/sendmail.postfix'
    notifies :stop, 'service[sendmail]'
    notifies :start, 'service[postfix]'
    not_if '/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix'
  end
end

service 'postfix' do
  action :start
end
