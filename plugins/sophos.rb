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
        hour = datetime[3].to_i
        minute = datetime[4].to_i
        second = datetime[5].to_i
        year = datetime[6].to_i
        update_date = Mash.new
        update_date[:time] = "%2d:%2d:%2d" % [ hour, minute, second ]
        update_date[:date] = {
          'day' => "%2d" % day,
          'month' => "%2d" % month,
          'year' => "%4d" % year
        }
        sophos[:last_update] = update_date
      end
    end

    return sophos
  end

  collect_data(:linux) do
    if sophos_bin()
      get_sophos_data
    end
  end

end
