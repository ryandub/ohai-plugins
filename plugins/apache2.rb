provides "apache2"

require_plugin 'linux::lsb'

def parse_apache_output(apache_command)
  return @parsed_apache if @parsed_apache
  response = {}
  output = retrieve_apache_output(apache_command)
  output[:stdout].each do |line|
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
  
  output[:stderr].each do |line|
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
  popen4("#{apache_command} -V") do |pid, stdin, stdout, stderr|
    stdin.close
    output[:pid] = pid
    output[:stdout] = stdout
  end
  popen4("#{apache_command} -S") do |pid, stdin, stdout, stderr|
    stdin.close
    output[:stderr] = stderr
  end
  return output
end

def count_apache_clients(apache_command)
  return (%x(ps -eo euser,ruser,suser,fuser,f,cmd |grep #{apache_command}|grep -v grep|wc -l).to_i - 1)
end

def find_apache_executable(os_name)
  if ["ubuntu", "debian"].include?(os_name)
    return %x(which apache2).strip
  elsif ["rhel", "centos"].include?(os_name)
    return %x(which httpd).strip
  else
    raise(RuntimeError, "Apache test cannot run on os type #{os_name}")
  end
end

if apache2_bin = find_apache_executable(lsb[:id].downcase)
  apache2 Mash.new
  apache2[:bin] = apache2_bin
  apache2[:clients] = count_apache_clients(apache2_bin)
  apache2.merge!(parse_apache_output(apache2_bin))

  apache2[:config_file] = apache2[:config_path] + "/" + apache2[:config_file]

  case apache2[:mpm]
  when "prefork"
    max_clients = %x(grep -A8 -i mpm_prefork_module #{apache2[:config_file]}|grep MaxClients).strip
    apache2[:max_clients] = (max_clients.split)[1].to_i
  end
end