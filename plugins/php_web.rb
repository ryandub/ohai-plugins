require 'time'

provides "php_web"

TIME_PATTERN = /^(.*):(\[[A-Z][a-z]{2} ([A-Z][a-z]{2} \d{2} \d{2}:\d{2}:\d{2} \d{4})\].*)/

def get_startup_errors()
    command = "php -v 2>&1 | grep '[wW]arning\\|[Ee]rror'"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)
    return stdout.split("\n")
end

def get_most_recent_error_date(errors)
    most_recent = errors.inject{ |most_recent,error|
        (error[0] > most_recent[0]) || (most_recent.nil?) ? error : most_recent
    }[0]
    return most_recent
end

def get_apache_errors()
    php_web[:status] = 1
    errors = []
    if File.exists?("/var/log/apache2")
        log_file = "/var/log/apache2"
    elsif File.exists?("/var/log/httpd")
        log_file = "/var/log/httpd"
    end
    command = "grep 'PHP Fatal error:' #{log_file}/*error*"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)
    errors = stdout.split("\n")
    php_web[:status] = 2
    errors.map! { |e|
        match_data = TIME_PATTERN.match(e)
        [Time.parse(match_data[3]), match_data[1], match_data[2]]
    }
    php_web[:status] = 3

    return errors
end

def weblog_file_locations()
  file_locs = []
  file_locs << "/var/log/apache2/*error*" if File.exists?("/var/log/apache2")
  file_locs << "/var/log/httpd/*error*" if File.exists?("/var/log/httpd")
  return file_locs
end

def php_bin()
  unless @php_bin
      status, stdout, stderr = run_command(:no_status_check => true,
                                           :command => "which php")
      php_bin = stdout.strip
  end
  return php_bin
end

if php_bin()
  php_web Mash.new
  php_web[:bin] = php_bin()
  startup_errors = get_startup_errors()
  if startup_errors.size > 0
    php_web[:startup_errors] = true
    php_web[:startup_error_count] = startup_errors.size
    php_web[:startup_error_lines] = startup_errors
  end
  log_files = weblog_file_locations()
  if log_files.size > 0
    errors = get_apache_errors()
    if errors.size > 0
      php_web[:errors] = true
      php_web[:error_count] = errors.size
      php_web[:error_lines] = errors
      php_web[:most_recent_error] = get_most_recent_error_date(errors)
    end
  end
end