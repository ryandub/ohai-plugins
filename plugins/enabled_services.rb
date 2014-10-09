# Encoding: utf-8
Ohai.plugin(:EnabledServices) do
  provides 'enabled_services'

  collect_data(:linux) do
    enabled_services Mash.new
    systemd = Dir.glob('/etc/systemd/system/multi-user.target.wants/*')
    systemd += Dir.glob('/etc/systemd/system/basic.target.wants/*')
    systemv = Dir.glob('/etc/rc3.d/S*')
    enabled_services['systemd'] = Array.new
    enabled_services['systemv'] = Array.new
    systemd.each do |entries|
      text = File.basename(entries)
      enabled_services['systemd'].push(text.split('.service')[0])
    end
    systemv.each do |entries|
      text = File.basename(entries)
      enabled_services['systemv'].push(text[3, text.size])
    end
    enabled_services['upstart'] = enabled_services['systemv']
    so = shell_out('dbus-send --print-reply --system --dest=com.ubuntu.Upstart'\
                   ' /com/ubuntu/Upstart com.ubuntu.Upstart0_6.GetAllJobs')
    so.stdout.lines do |line|
      if line.include? 'jobs'
        name = line.split('jobs/')[1].strip
        enabled_services['upstart'].push(name.chomp('"'))
      end
    end
  end
end
