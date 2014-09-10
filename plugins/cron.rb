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
      response[name] = Array.new
      so = shell_out("cat #{file}")
      so.stdout.lines.each do |line|
        case line
        when /^#/, /^PATH/, /^MAILTO/
          next
        when /^@reboot/, /^@hourly/, /^@daily/, /^@monthly/, /^@weekly/
          job = {}
          info = line.split(' ')
          length = info.count - 1
          job[:time] = info[0]
          job[:command] = info[1..length].join(' ')
          response[name] << job
        # rubocop:disable Metrics/LineLength
        when %r{^\s*(\w+\s*=|(\*(?:/\d+)?|(?:[0-5]?\d)(?:-(?:[0-5]?\d)(?:/\d+)?)?(?:,(?:[0-5]?\d)(?:-(?:[0-5]?\d)(?:/\d+)?)?)*)\s+(\*(?:/\d+)?|(?:[01]?\d|2[0-3])(?:-(?:[01]?\d|2[0-3])(?:/\d+)?)?(?:,(?:[01]?\d|2[0-3])(?:-(?:[01]?\d|2[0-3])(?:/\d+)?)?)*)\s+(\*(?:/\d+)?|(?:0?[1-9]|[12]\d|3[01])(?:-(?:0?[1-9]|[12]\d|3[01])(?:/\d+)?)?(?:,(?:0?[1-9]|[12]\d|3[01])(?:-(?:0?[1-9]|[12]\d|3[01])(?:/\d+)?)?)*)\s+(\*(?:/\d+)?|(?:[1-9]|1[012])(?:-(?:[1-9]|1[012])(?:/\d+)?)?(?:,(?:[1-9]|1[012])(?:-(?:[1-9]|1[012])(?:/\d+)?)?)*)\s+(\*(?:/\d+)?|(?:[0-6])(?:-(?:[0-6])(?:/\d+)?)?(?:,(?:[0-6])(?:-(?:[0-6])(?:/\d+)?)?)*|mon|tue|wed|thu|fri|sat|sun)\s+)([^\s]+)\s+(.*)$}
          # rubocop:enable Metrics/LineLength
          job = {}
          info = line.split(' ')
          length = info.count - 1
          job[:m] = info[0]
          job[:h] = info[1]
          job[:dom] = info[2]
          job[:mon] = info[3]
          job[:dow] = info[4]
          job[:command] = info[5..length].join(' ')
          response[name] << job
        else
          next
        end
      end
    end
    return response
  end

  collect_data(:linux) do
    jobs = parse_cronjobs
    unless jobs.empty?
      cronjobs Mash.new
      cronjobs.merge!(jobs)
    end
  end
end
