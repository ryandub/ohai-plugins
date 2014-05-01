# Encoding: UTF-8
Ohai.plugin(:Crontab) do
  provides 'cronjobs'
  depends 'platform_family'

  def parse_cronjobs
    response = {}
    case platform_family
    when 'rhel'
      cron_dir = '/var/spool/cron/*'
    when 'debian'
      cron_dir = '/var/spool/cron/crontabs/*'
    end
    files = Dir.glob(cron_dir).select { |f| !File.directory? f }
    files.each do |file|
      name = File.basename(file)
      response[name] = {}
      so = shell_out("cat #{file}")
      so.stdout.lines do |line|
        case line
        when /^#/
          next
        when /^@reboot/, /^@hourly/, /^@daily/, /^@monthly/, /^@weekly/
          info = line.split(' ')
          length = info.count - 1
          response[name][:time] = info[0]
          response[name][:command] = info[1..length].join(' ')
        when /^\s*(\w+\s*=|(\*(?:\/\d+)?|(?:[0-5]?\d)(?:-(?:[0-5]?\d)(?:\/\d+)?)?(?:,(?:[0-5]?\d)(?:-(?:[0-5]?\d)(?:\/\d+)?)?)*)\s+(\*(?:\/\d+)?|(?:[01]?\d|2[0-3])(?:-(?:[01]?\d|2[0-3])(?:\/\d+)?)?(?:,(?:[01]?\d|2[0-3])(?:-(?:[01]?\d|2[0-3])(?:\/\d+)?)?)*)\s+(\*(?:\/\d+)?|(?:0?[1-9]|[12]\d|3[01])(?:-(?:0?[1-9]|[12]\d|3[01])(?:\/\d+)?)?(?:,(?:0?[1-9]|[12]\d|3[01])(?:-(?:0?[1-9]|[12]\d|3[01])(?:\/\d+)?)?)*)\s+(\*(?:\/\d+)?|(?:[1-9]|1[012])(?:-(?:[1-9]|1[012])(?:\/\d+)?)?(?:,(?:[1-9]|1[012])(?:-(?:[1-9]|1[012])(?:\/\d+)?)?)*)\s+(\*(?:\/\d+)?|(?:[0-6])(?:-(?:[0-6])(?:\/\d+)?)?(?:,(?:[0-6])(?:-(?:[0-6])(?:\/\d+)?)?)*|mon|tue|wed|thu|fri|sat|sun)\s+)([^\s]+)\s+(.*)$/
          info = line.split(' ')
          length = info.count - 1
          response[name][:m] = info[0]
          response[name][:h] = info[1]
          response[name][:dom] = info[2]
          response[name][:mon] = info[3]
          response[name][:dow] = info[4]
          response[name][:command] = info[5..length].join(' ')
        end
        return response
      end
    end
  end

  collect_data(:linux) do
    jobs = parse_cronjobs
    unless jobs.empty?
      cronjobs Mash.new
      cronjobs.merge!(jobs)
    end
  end
end
