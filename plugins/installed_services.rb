# Encoding: utf-8
Ohai.plugin(:InstalledServices) do
  provides 'installed_services'

  collect_data(:linux) do
    installed_services Mash.new
    initd = Dir.glob('/etc/init.d/*')
    init = Dir.glob('/etc/init/*')
    system = Dir.glob('/usr/lib/systemd/system/*')
    installed_services['initd'] = Array.new
    installed_services['init'] = Array.new
    installed_services['system'] = Array.new
    initd.each do |entries|
      text = File.basename(entries)
      installed_services['initd'].push(text.split(' ')[0])
    end
    init.each do |entries|
      text = File.basename(entries)
      installed_services['init'].push(text.split('.conf')[0])
    end
    system.each do |entries|
      text = File.basename(entries)
      installed_services['system'].push(text.split('.service')[0])
    end
  end
end
