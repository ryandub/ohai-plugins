Ohai.plugin(:Postfix) do
 provides 'postfix'
 
 depends 'packages'
 depends 'processes'
 
 def find_postfix_executable
  so = shell_out("/bin/bash -c 'command -v postfix'")
  postfix_bin = so.stdout.strip
  return postfix_bin
 end

 def find_postfix_process
  unless @postfix_process
   command= "ps -eo euser,ruser,suser,fuser,f,cmd|grep master|grep -v grep"
   so = shell_out(command)
   postfix_process = so.stdout.split(' ')[5].chomp
  end
  return postfix_process unless postfix_process.empty?
 end
 
  def check_postfix_configuration
   postconf={}
   response={}   
    configuration_files={}
        
   importantKeys = {
    "inet_interfaces" => "Postfix Listening On Addresses",
    "inet_protocols" => "IP protocols in use",
    "myhostname" => "Postfix Hostname",
    "mydomain" => "Postfix Domain Name",
    "mydestination" => "Postfix Final Destinations",
    "mynetworks" => "Postfix Trusted Client Networks",
    "myorigin" => "Postfix Origin Address",
    "alias_database" => "Postfix Aliases Database",
    "config_directory" => "Postfix Configuration Directory"
   }
      
   postconfOutput = shell_out('postconf')

   postconfOutput.stdout.lines do |line|
    fields = line.split(' = ')
    postconf[fields[0]] = fields[1].chomp
    end
   
   importantKeys.each do |key, value|
    response[value] = postconf[key]
   end
    response[:"Postfix Configuration Files"] = Dir.glob(postconf['config_directory']+"/*")
   
   return response
  end  
    
  
  collect_data(:linux) do
    postfix Mash.new
    postfix[:postfix_binary] = find_postfix_executable
    postfix[:postfix_package] = packages[:postfix]
    postfix[:process] = find_postfix_process
    postfix[:config_dir] = postfix_config_dir
    postfix[:current_configuration] = check_postfix_configuration
  end
end
