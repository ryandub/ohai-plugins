Ohai.plugin(:Apache2) do
  provides 'apache2'
  depends 'platform', 'platform_family'

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
        errors = $1.split(": ")
        errors[0] = "Syntax error " + errors[0]
        response[:syntax_errors] = errors
      end
    end

    return @parsed_apache = response
  end

  def retrieve_apache_output(apache_command)
    output = {}
    so = shell_out("#{apache_command} -V")
    output[:stdout] = so.stdout
    if platform_family == "debian"
      so = shell_out("#{apache_command} -t")
      output[:stderr] = so.stderr
    elsif platform_family == "rhel"
      so = shell_out("#{apache_command} -S")
      output[:stderr] = so.stderr
    end
    return output
  end

  def count_apache_clients(apache_command)
    command = "ps -eo euser,ruser,suser,fuser,f,cmd |grep #{apache_command}|grep -v grep|wc -l"
    so = shell_out(command)
    return so.stdout.to_i
  end

  def find_apache_executable(platform_family)
    if platform_family == "debian"
      so = shell_out("command -v apache2")
      apache2_bin = so.stdout.strip
    elsif platform_family == "rhel"
      so = shell_out("command -v httpd")
      apache2_bin = so.stdout.strip
    else
      raise(RuntimeError, "Apache test cannot run on os type #{platform_family}")
    end

    return apache2_bin unless apache2_bin.empty?
  end

  def find_apache_user(platform_family)
    if platform_family == "debian"
      so = shell_out("ps -ef|awk '/apache2/ && !/root/ {print $1}' | uniq")
      apache_user = so.stdout.strip
    elsif platform_family == "rhel"
      so = shell_out("ps -ef|awk '/httpd/ && !/root/ {print $1}' | uniq")
      apache_user = so.stdout.strip
    else
      raise(RuntimeError, "Apache test cannot run on os type #{platform_family}")
    end

    return apache_user unless apache_user.empty?
  end

  def find_apache2ctl()
    so = shell_out("command -v apache2ctl")
    return so.stdout.strip
  end

  collect_data(:linux) do
    if apache2_bin = find_apache_executable(platform_family)
      apache2 Mash.new
      apache2[:bin] = apache2_bin
      apache2[:clients] = count_apache_clients(apache2_bin)
      apache2[:user] = find_apache_user(platform_family)
      if platform_family == "debian"
        apache2ctl_bin = find_apache2ctl()
      end
      apache2.merge!(parse_apache_output(apache2ctl_bin || apache2_bin))
      if apache2[:config_path] == '"'
        apache2[:config_path] = File.dirname(apache2[:config_file])
      else
        apache2[:config_file] = File.join(apache2[:config_path], apache2[:config_file])
      end

      case apache2[:mpm]
      when "prefork"
        command = "grep -A8 -i mpm_prefork_module #{apache2[:config_file]}|grep MaxClients"
        so = shell_out(command)
        max_clients = so.stdout.strip
        max_clients = (max_clients.split)[1].to_i
        if max_clients > 0
          apache2[:max_clients] = max_clients
        end
      end
    end
  end
end
