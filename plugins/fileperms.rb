# Encoding: UTF-8
Ohai.plugin(:Permissions) do
  provides 'permissions'

  

  def file_perms(filename)
  	command = <<-EOS
  	  stat -L -c "%a" filename
    EOS
    so = shell_out(command)
    return so.stdout.to_i
  end
  
  collect_data(:linux) do
  	permissions Mash.new
  	file = [
  		"/etc/grub.conf",
  		"/boot/grub/grub.cfg",
  		"/etc/passwd",
  		"/etc/shadow",
  		"/etc/hosts.allow",
  		"/etc/hosts.deny",
  		"/etc/anacrontab",
  		"/etc/crontab",
  		"/etc/cron.hourly",
  		"/etc/cron.daily",
  		"/etc/cron.weekly",
  		"/etc/cron.monthly",
  		"/etc/cron.d",
  		"/etc/ssh/sshd_config",
  		"/etc/gshadow",
  		"/etc/group",
    ]
  	file.each do |file|
  		if File.exists?(file) do
  		  permissions[:file] = file_perms(file)
  		end
  	end
  end
end
