# Encoding: UTF-8
Ohai.plugin(:Permissions) do
  provides 'permissions'

  def file_perms(file)
    command = <<-EOS
    stat -L -c "%a" #{file}
    EOS
    so = shell_out(command)
    so.stdout.to_i
  end

  collect_data(:linux) do
    file = [
      '/etc/grub.conf',
      '/boot/grub/grub.cfg',
      '/etc/passwd',
      '/etc/shadow',
      '/etc/hosts.allow',
      '/etc/hosts.deny',
      '/etc/anacrontab',
      '/etc/crontab',
      '/etc/cron.hourly',
      '/etc/cron.daily',
      '/etc/cron.weekly',
      '/etc/cron.monthly',
      '/etc/cron.d',
      '/etc/ssh/sshd_config',
      '/etc/gshadow',
      '/etc/group',
      '/etc/login.defs',
      '/var/run/php-fpm.sock'
    ]
    permissions Mash.new
    file.each do |filename|
      if File.file?("#{filename}")
        permissions["#{filename}"] = file_perms("#{filename}")
      end
    end
  end
end
