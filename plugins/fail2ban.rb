Ohai.plugin(:Fail2ban) do
  provides 'fail2ban'

  def logfile_path
    so = shell_out('fail2ban-client get logtarget')
    logline = so.stdout.split("\n")[1]
    loglocation = logline.split(' ')[1]
    Ohai::Log.debug("fail2ban log location: #{loglocation}")

    if loglocation == 'SYSLOG'
      loglocation = '/var/log/syslog'
      loglocation = '/var/log/messages' if File.exist?('/var/log/messages')
    end

    loglocation
  end

  def jails_list
    so = shell_out('fail2ban-client status')
    lines = so.stdout.split("\n")
    Ohai::Log.debug("fail2ban status: #{lines}")
    comma_jails = lines[2].split("\t\t")[1]
    list_of_jails = [*comma_jails.split(', ')]
    Ohai::Log.debug("fail2ban jails: #{list_of_jails}")
    list_of_jails
  end

  def activity_log
    logfile = logfile_path

    so = shell_out("grep -e ' Ban \\| Unban ' #{logfile}")
    lines = so.stdout.split("\n")
    Ohai::Log.debug("fail2ban ban lines: #{lines}")

    lines
  end

  def banned_stats(activity)
    ban_stats = {}
    activity.each do |line|
      words = line.split(' ')
      ip = words[-1]
      status = words[-2]
      jail = words[-3].tr('][', '')

      if ban_stats[ip] && ban_stats[ip][jail]
        ban = ban_stats[ip][jail]
      else
        ban = { count: 0, status: 'None' }
      end
      ban[:count] += 1 if line.include? 'Ban'
      ban[:status] = status
      ban_stats[ip] = {} unless ban_stats[ip]
      ban_stats[ip][jail] = ban
    end
    Ohai::Log.debug("Ban Stats: #{ban_stats}")
    ban_stats
  end

  collect_data(:linux) do
    activity = activity_log
    jails = jails_list
    banned = banned_stats(activity)

    fail2ban Mash.new unless activity.empty? && jails.empty?
    Ohai::Log.debug(activity[-500..-1] || activity)
    fail2ban[:activity] = (
      activity[-500..-1] || activity) unless activity.empty?
    fail2ban[:jails] = jails unless jails.empty?
    fail2ban[:banned] = banned unless banned.empty?
    Ohai::Log.debug("Final fail2ban data: #{fail2ban}")
  end
end
