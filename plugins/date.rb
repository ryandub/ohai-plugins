# Encoding: utf-8
require 'time'

Ohai.plugin(:Date) do
  provides 'datetimeinfo'

  collect_data(:linux) do
    datetimeinfo Mash.new
    date = Time.now.strftime('%H:%M:%S %Y %m %d %Z').split(' ')
    datetimeinfo[:timezone] = date[4]
    datetimeinfo[:time] = date[0]
    datetimeinfo[:date] = {
      'month' => date[2],
      'day'   => date[3],
      'year'  => date[1]
    }
  end
end
