require 'time'

provides "php_web"

TIME_PATTERN = /^(.*):(\[[A-Z][a-z]{2} ([A-Z][a-z]{2} \d{2} \d{2}:\d{2}:\d{2} \d{4})\].*)/
php_web Mash.new

errors = []
if File.exists?("/var/log/apache2") 
  errors = (`grep 'PHP Fatal error:' /var/log/apache2/*error*`).split("\n")
elsif File.exists?("/var/log/httpd")
  errors = (`grep 'PHP Fatal error:' /var/log/httpd/*error*`).split("\n")
end

errors.map! { |e|
  match_data = TIME_PATTERN.match(e)
  [Time.parse(match_data[3]), match_data[1], match_data[2]]
}

most_recent = errors.inject{ |most_recent,error|
  (error[0] > most_recent[0]) || (most_recent.nil?) ? error : most_recent
}[0]

php_web[:errors] = errors.size > 0
php_web[:error_count] = errors.size
php_web[:error_lines] = errors
php_web[:most_recent_error] = most_recent