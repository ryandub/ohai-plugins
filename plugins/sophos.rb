# Encoding utf-8
Ohai.plugin(:Sophos) do
  require 'date'
  provides 'sophos'

  def sophos_bin()
    if File.exist?('/opt/sophos-av/bin/savdstatus')
      return true
    end
  end

  def get_sophos_data()
    sophos Mash.new
    so = shell_out("/opt/sophos-av/bin/savdstatus --version")
    so.stdout.lines do |line|
      version = /Sophos Anti-Virus[[:space:]]+=[[:space:]]+([0-9.]+)/.match(line)
        if version
          sophos[:version] = version[1]
          next
        end
      last_update = /Last update[[:space:]]+=[[:space:]]+(.*)/.match(line)
      if last_update

        datetime = /[[:alpha:]]{3} ([[:alpha:]]{3})[[:space:]]{1,2}([[:digit:]]{1,2}) ([[:digit:]]{2}):([[:digit:]]{2}):([[:digit:]]{2}) ([[:digit:]]{4})/.match(last_update[1])

        month = Date::ABBR_MONTHNAMES.index(datetime[1])
        day = datetime[2].to_i
        hour = datetime[3]
        minute = datetime[4]
        second = datetime[5]
        year = datetime[6]
        update_date = Mash.new
        update_date[:time] = "%s:%s:%s" % [ hour, minute, second ]
        update_date[:date] = {
          'day' => "%02d" % day,
          'month' => "%02d" % month,
          'year' => year
        }
        sophos[:last_update] = update_date
      end
    end

    return sophos
  end

  def check_active(filename)
    
    if File.exists?(filename)

      status_file = File.new(filename, 'r')
      line = status_file.gets
      if (line.chomp() == 'active')
        return 'active'

      end
    end

    return 'inactive'
  end

  def get_sophos_status(sophos)
    
    sophos[:onaccess_status] = check_active("/opt/sophos-av/var/run/onaccess.status")
    sophos[:savd_status] = check_active("/opt/sophos-av/var/run/savd.status")
    sophos[:av_status] = check_active("/opt/sophos-av/var/run/av.status")

    return sophos
  end

  collect_data(:linux) do
    if sophos_bin()

      sophos = get_sophos_data
      sophos = get_sophos_status(sophos)

    end
  end

end
