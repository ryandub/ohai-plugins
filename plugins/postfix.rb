Ohai.plugin(:Postfix) do
 provides 'postfix'
 depends 'platform_family'
 depends 'packages'
 depends 'processes'
 
 def find_postfix_executable
  so = shell_out("/bin/bash -c 'command -v postfix'")
  postfix_bin = so.stdout.strip
  return postfix_bin
 end

 def postfix_config_dir(platform_family)
  case platform_family
   when 'rhel'
    so = shell_out('postconf |grep ^config_directory')
    postfix_config_dir=so.stdout.split(' = ')[1].chomp
   when 'debian'
    so = shell_out('postconf |grep ^config_directory')
    postfix_config_dir=so.stdout.split(' = ')[1].chomp
   end
   return postfix_config_dir
 end

 def find_postfix_process
  unless @postfix_process
   command= "ps -eo euser,ruser,suser,fuser,f,cmd|grep master|grep -v grep"
   so = shell_out(command)
   postfix_process = so.stdout.split(' ')[5].chomp
  end
  return postfix_process unless postfix_process.empty?
 end

 def postfix_config_files(platform_family)
  case platform_family
   when 'rhel'
    postfix_config_files = Dir.glob(postfix_config_dir(platform_family)+"/*")
   when 'debian'
    postfix_config_files = Dir.glob(postfix_config_dir(platform_family)+"/*")
   end
    return postfix_config_files
  end
 
  def check_postfix_configuration
   postconf={}
   response={}   
     
   importantKeys = {
    "inet_interfaces" => "Postfix Listening On Addresses",
    "inet_protocols" => "IP protocols in use",
    "myhostname" => "Postfix Hostname",
    "mydomain" => "Postfix Domain Name",
    "mydestination" => "Postfix Final Destinations",
    "mynetworks" => "Postfix Trusted Client Networks",
    "myorigin" => "Postfix Origin Address",
    "allias_database" => "Postfix Aliases Database"
   }
      
   postconfOutput = shell_out('postconf')

   postconfOutput.stdout.lines do |line|
    fields = line.split(' = ')
    postconf[fields[0]] = fields[1].chomp
   end
   
   important_keys.each do |key, value|
    response[value] = postconf[key]
   end
   return response
  end  
    
  
  collect_data(:linux) do
   if packages[:postfix]
    postfix Mash.new
    postfix[:postfix_binary] = find_postfix_executable
    postfix[:postfix_package] = packages[:postfix]
    postfix[:process] = find_postfix_process
    postfix[:config_dir] = postfix_config_dir(platform_family)
    postfix[:config_files] = postfix_config_files(platform_family)
    postfix[:current_configuration] = check_postfix_configuration
   else
    if find_postfix_executable
     postfix Mash.new
     postfix[:INFO] = "Postfix is not installed from RPM/DEB packages"
    end
   end
  end
end
