Ohai.plugin(:Fail2ban) do
  provides 'fail2ban'

  def get_logfile()
    so = shell_out('fail2ban-client get logtarget')
    logline = so.stdout.split("\n")[1]
    loglocation = logline.split(' ')[1]
    Ohai::Log.debug(loglocation)

    if loglocation == 'SYSLOG'
      return '/var/log/messages' if File.exist?('/var/log/messages')

      return '/var/log/syslog'
    end

    return loglocation
  end

  def get_jails()
    so = shell_out('fail2ban-client status')
    lines = so.stdout.split("\n")
    Ohai::Log.debug(lines)
    comma_jails = lines[2].split("\t\t")[1]
    list_of_jails = [*comma_jails.split(", ")]
    Ohai::Log.debug(list_of_jails)
    return list_of_jails
  end

  def get_activity()
    logfile = get_logfile()

    so = shell_out("grep -e 'Ban\\|Unban' #{logfile}")
    lines = so.stdout.split("\n")
    Ohai::Log.debug(lines)

    return lines
  end

  collect_data(:linux) do
    fail2ban Mash.new

    fail2ban[:activity] = get_activity()
    fail2ban[:jails] = get_jails()
  end
end
