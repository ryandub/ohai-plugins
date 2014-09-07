# Encoding: utf-8

Ohai.plugin(:Apache2) do
  provides 'apache2'
  depends 'platform', 'platform_family'

  # rubocop:disable Metrics/CyclomaticComplexity
  def parse_apache_output(apache_command)
    return @parsed_apache if @parsed_apache
    response = {}
    output = retrieve_apache_output(apache_command)
    output[:stdout].lines do |line|
      case line
      when /-D HTTPD_ROOT=["']?(.+?)["']?$/
        response[:config_path] = $1
      when /Server version:\s(.+?)?$/
        response[:version] = $1
      when /Server MPM:\s(.+?)?$/
        response[:mpm] = $1.strip.downcase
      when /-D SERVER_CONFIG_FILE=["']?(.+?)["']?$/
        response[:config_file] = $1.strip
    end
    end

    output[:stderr].lines do |line|
      case line
      when /WARNING: Require MaxClients > 0, setting to\s(.+?)?$/
        response[:max_clients] = $1.to_i
      when /Syntax OK/
        response[:syntax_ok] = true
      when /Syntax error\s(.+?)?$/
        response[:syntax_ok] = false
        errors = $1.split(': ')
        errors[0] = 'Syntax error ' + errors[0]
        response[:syntax_errors] = errors
    end
    end

    @parsed_apache = response
    @parsed_apache
  end

  def parse_vhosts(apache_command)
    response = {}
    current_vhost = ''
    so = shell_out("#{apache_command} -S 2>&1")
    so.stdout.lines do |line|
      case line
      when /is a NameVirtualHost/
        current_vhost = line.split[0]
        response[:vhosts] ||= {}
        response[:vhosts][current_vhost] = {}
      when /^(\s)*default\s/
        response[:vhosts] ||= {}
        response[:vhosts][current_vhost] ||= {}
        vhost = line.split[2]
        conf = line.split[3].gsub(/\(|\)/, '')
        configs = parse_vhost_config(conf.split(':')[0], conf.split(':')[1])
        response[:vhosts][current_vhost]['default'] = {
          vhost: vhost,
          conf: conf,
          docroot: configs['docroot'],
          accesslogs: configs['access_logs'],
          errorlog: configs['error_log']
        }
      when /^(\s)*port\s/
        response[:vhosts] ||= {}
        response[:vhosts][current_vhost] ||= {}
        vhost = line.split[3]
        conf = line.split[4].gsub(/\(|\)/, '')
        port = line.split[1]
        configs = parse_vhost_config(conf.split(':')[0], conf.split(':')[1])
        response[:vhosts][current_vhost][line.split[3]] ||= {
          vhost: vhost,
          conf: conf,
          port: port,
          docroot: configs['docroot'],
          accesslogs: configs['access_logs'],
          errorlog: configs['error_log']
        }
      end
    end
    response
  end

  def parse_vhost_config(file, line_number)
    docroot = nil
    access_logs = []
    error_log = nil
    begin
      f = File.open(file)
      line_number.to_i.times { f.gets }
      f.each do |line|
        case line
        when /^(?!#)(\s+)?DocumentRoot\s.*/
          # If the line has comments after DocumentRoot,
          # we don't want to return those.
          line = strip_comments(line)
          # Parse the docroot line and account for possible spaces and quotes.
          docroot = line.lstrip.strip.split(' ')[1..-1].join(' ').to_s.gsub(
            /(\"|\')/, '')
        when /^(?!#)(\s+)?ErrorLog\s.*/
          line = strip_comments(line)
          error_log = line.lstrip.strip.split(' ')[1..-1].join(' ').to_s.gsub(
            /(\"|\')/, '')
        when /^(?!#)(\s+)?CustomLog\s.*/
          line = strip_comments(line)
          access_logs << line.lstrip.strip.split(' ')[1..-1].join(
            ' ').to_s.gsub(/(\"|\')/, '')
        when /^(?!#)(\s+)?<\/VirtualHost>\s.*/
          break
        end
      end
    ensure
      # Make sure we close the file even if there is an error.
      f.close
    end

    config = { 'docroot'     => docroot,
               'access_logs' => access_logs,
               'error_log'   => error_log }

    config
  end

  def retrieve_apache_output(apache_command)
    output = {}
    so = shell_out("#{apache_command} -V")
    output[:stdout] = so.stdout
    if platform_family == 'debian'
      so = shell_out("#{apache_command} -t")
      output[:stderr] = so.stderr
    elsif platform_family == 'rhel'
      so = shell_out("#{apache_command} -S")
      output[:stderr] = so.stderr
    end
    output
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def strip_comments(text)
    re = Regexp.union(['#'])
    # rubocop:disable Lint/AssignmentInCondition
    if index = (text =~ re)
      # rubocop:enable Lint/AssignmentInCondition
      return text[0, index].rstrip
    else
      return text
    end
  end

  def count_apache_clients(apache_command, apache_user)
    command = "ps -u #{apache_user} -o cmd| grep -c  #{apache_command}"
    so = shell_out(command)
    so.stdout.to_i
  end

  def find_apache_executable(platform_family)
    if platform_family == 'debian'
      so = shell_out("/bin/bash -c 'command -v apache2'")
      apache2_bin = so.stdout.strip
    elsif platform_family == 'rhel'
      so = shell_out("/bin/bash -c 'command -v httpd'")
      apache2_bin = so.stdout.strip
    else
      fail("Apache test cannot run on os type #{platform_family}")
    end

    return apache2_bin unless apache2_bin.empty?
  end

  def find_apache_user(platform_family)
    if platform_family == 'debian'
      so = shell_out("ps -ef|awk '/apache2/ && !/root/ {print $1}' | uniq")
      apache_user = so.stdout.strip
    elsif platform_family == 'rhel'
      so = shell_out("ps -ef|awk '/httpd/ && !/root/ {print $1}' | uniq")
      apache_user = so.stdout.strip
    else
      fail("Apache test cannot run on os type #{platform_family}")
    end

    return apache_user unless apache_user.empty?
  end

  def find_apache2ctl
    so = shell_out("/bin/bash -c 'command -v apache2ctl'")
    so.stdout.strip
  end

  def estimate_ram_per_prefork_child(platform_family, apache2_user)
    command = "ps -u #{apache2_user} -o pid= | xargs pmap -d | awk '/private/ \
               {c+=1; sum+=$4} END {printf \"%.2f\", sum/c/1024}'"

    if platform_family == 'debian'
      so = shell_out(command)
      return a2_ram_per_child = so.stdout.strip.to_f
    elsif platform_family == 'rhel'
      so = shell_out(command)
      return a2_ram_per_child = so.stdout.strip.to_f
    else
      fail("Apache RAM per prefork estimate cannot run on os \
           type #{platform_family}")
    end

    return a2_ram_per_child unless a2_ram_per_child.empty?
  end

  collect_data(:linux) do
    apache2_bin = find_apache_executable(platform_family)
    if apache2_bin
      apache2 Mash.new
      apache2[:bin] = apache2_bin
      apache2[:user] = find_apache_user(platform_family)
      apache2[:clients] = count_apache_clients(apache2_bin, apache2[:user])

      # Use apache2ctl if platform is Debian based.
      apache2ctl_bin = find_apache2ctl if platform_family == 'debian'

      apache2.merge!(parse_apache_output(apache2ctl_bin || apache2_bin))
      apache2.merge!(parse_vhosts(apache2ctl_bin || apache2_bin))
      if apache2[:config_path] == '"'
        apache2[:config_path] = File.dirname(apache2[:config_file])
      else
        apache2[:config_file] = File.join(apache2[:config_path],
                                          apache2[:config_file])
      end

      case apache2[:mpm]
      when 'prefork'
        apache2[:estimatedRAMperpreforkchild] = estimate_ram_per_prefork_child(
          platform_family, apache2[:user])
        max_clients = 0
        inside_prefork_block = false
        File.open(apache2[:config_file], 'r') do |apache2_config|
          apache2_config.each_line do |line|
            inside_prefork_block = true if /<IfModule.*prefork.*/.match(line)
            if inside_prefork_block && /^\s*MaxClients/.match(line)
              max_clients = line.split[1].to_i
              break
            end
            break if /<\\IfModule/.match(line)
          end
        end
        if max_clients > 0
          apache2[:max_clients] = max_clients
        else
          Ohai::Log.debug("Unable to parse max_clients from \
                           #{apache2[:config_file]}")
        end
      end
    end
  end
end
