# Encoding: utf-8
Ohai.plugin(:Autoupdates) do
  provides 'autoupdates'
  depends 'platform', 'platform_family', 'packages'

  def scheduled?
    case platform_family
    when 'rhel'
      so = shell_out('service yum-cron status')
      if so.status == 0
        return true
      else
        return false
      end
    when 'debian'
      enabled_config = false
      so = shell_out('apt-config dump')
      so.stdout.lines do |line|
        if line.strip =~ /APT::Periodic::Unattended-Upgrade \"1\"/
          enabled_config = true
        end
      end
      return true if enabled_config && File.exist?('/etc/cron.daily/apt')
    end
  end

  def update_status
    status = {}
    case platform_family
    when 'rhel'
      status['yum-cron'] = 'uninstalled'
      if packages.key?('yum-cron')
        status['yum-cron'] = 'disabled'
        status['yum-cron'] = 'enabled' if scheduled?
      end
    when 'debian'
      status['unattended-upgrades'] = 'uninstalled'
      if packages.key?('unattended-upgrades')
        status['unattended-upgrades'] = 'disabled'
        status['unattended-upgrades'] = 'enabled' if scheduled?
      end
    end
    return status
  end

  collect_data(:linux) do
    status = update_status
    unless status.empty?
      autoupdates Mash.new
      autoupdates.merge!(status)
    end
  end
end
