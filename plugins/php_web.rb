require 'time'

provides "php_web"

TIME_PATTERN = /^(.*):(\[[A-Z][a-z]{2} ([A-Z][a-z]{2} \d{2} \d{2}:\d{2}:\d{2} \d{4})\].*)/

def get_startup_errors()
    return (`php -v 2>&1 | grep '[wW]arning\\|[Ee]rror'`).split("\n")
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
        errors = (`tail -n 5000 /var/log/apache2/*error* | grep 'PHP Fatal error:'`).split("\n")
    elsif File.exists?("/var/log/httpd")
        errors = (`tail -n 5000 /var/log/httpd/*error* | grep 'PHP Fatal error:'`).split("\n")
    end
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
  return @php_bin ||= %x(which php).strip
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