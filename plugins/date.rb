Ohai.plugin(:Date) do
  provides "date"

  collect_data(:linux) do
    datetimeinfo Mash.new
    date = shell_out('date +"%a %B %d %Y %R %Z"').stdout.split("\s")

    datetimeinfo[:timezone] = date[5]
    datetimeinfo[:time] = date[4]
    datetimeinfo[:date] = date.shift(4)
  end
end
