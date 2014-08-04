for dir in ['/opt/sophos-av/etc', '/opt/sophos-av/var/run', '/opt/sophos-av/engine']
  directory dir do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recurseive true
  end
end

test_data = {
  '/opt/sophos-av/engine/version' => "9.6.1\n",
  '/opt/sophos-av/bin/savdstatus' => "0",
  '/opt/sophos-av/etc/update.last_update' => "1407146742\n",
  '/opt/sophos-av/var/run/onaccess.status' => 'inactive',
  '/opt/sophos-av/var/run/savd.status' => 'active',
  '/opt/sophos-av/var/run/av.status' => 'active'
}

for test_file in test_data.keys

  file test_file do
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    content test_data[test_file]
  end
end

