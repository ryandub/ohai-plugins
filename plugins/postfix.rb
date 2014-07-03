Ohai.plugin(:Postfix) do
  provides 'postfix'
  depends 'platform_family'

  def find_postfix_executable(platform_family)
    case platform_family
    when 'rhel'
      so = shell_out("/bin/bash -c 'command -v postfix'")
      postfix_bin = so.stdout.strip  
    when 'debian'
      so = shell_out("/bin/bash -c 'command -v postfix'")
      postfix_bin = so.stdout.strip
    end
    return postfix_bin
    
  end   
  
  def find_postfix_package(platform_family)
    case platform_family
    when 'rhel'
      so = shell_out("rpm -q postfix")
      postfix_package = so.stdout.strip  
    when 'debian'
      so = shell_out("dpkg -l postfix |grep ^ii")
      postfix_package = so.stdout.strip[4..69]
    end
    return postfix_package
  end  
  
  def find_postfix_process
      unless @postfix_process
      command= "ps -eo euser,ruser,suser,fuser,f,cmd|grep master|grep -v grep"
      so = shell_out(command)
      postfix_process = so.stdout.strip
      end
  return postfix_process unless postfix_process.empty?
  end

  def  postfix_config_dir(platform_family)
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

  def  postfix_config_files(platform_family)
     case platform_family
     when 'rhel'
       postfix_config_files = Dir.glob(postfix_config_dir(platform_family)+"/*")
 
     when 'debian'
       postfix_config_files = Dir.glob(postfix_config_dir(platform_family)+"/*")
     end
     return postfix_config_files
   end

   def check_configuration
     #
     #  we are only looking at 
     #  some basic configuration metrics
     # related to LOCAL and REMOTE mail delivery
     # 
     
     response = {}
     so = shell_out('postconf')
     so.stdout.lines do |line|
       case line
          when /^inet_interfaces/
           interfaces = line.split(' = ')[1].chomp
           response[:network_interface]=interfaces
          when /^inet_protocols /
           postfix_inet_protocols = line.split(' = ')[1].chomp
           response[:inet_protocols] = postfix_inet_protocols             
          when /^myhostname/
           postfix_hostname = line.split(' = ')[1].chomp
           response[:myhostname] = postfix_hostname
          when /^mydomain/
           postfix_domain = line.split(' = ')[1].chomp
           response[:mydomain] = postfix_domain
          when /^mydestination/
           postfix_destinations = line.split(' = ')[1].chomp
           response[:mydestination] = postfix_destinations                  
          when /^mynetworks /
           postfix_networks = line.split(' = ')[1].chomp
           response[:mynetworks] = postfix_networks
          when /^myorigin /
           postfix_origin = line.split(' = ')[1].chomp
           if postfix_origin.include? "myhostname"
            response[:myorigin] = response[:myhostname]
           elsif postfix_origin.include? "mydomain"
            response[:myorigin] = response[:mydomain]
           else
             response[:myorigin] = postfix_origin
           end                       
          when /^alias_database /
           postfix_aliases = line.split(' = ')[1].chomp
           response[:alias_database] = postfix_aliases               
       end
     end
     response
   end
   
    collect_data(:linux) do
      if find_postfix_package(platform_family)
              postfix Mash.new
              postfix[:postfix_binary] = find_postfix_executable(platform_family)
              postfix[:postfix_package] = find_postfix_package(platform_family)
              postfix[:process] = find_postfix_process
              postfix[:config_dir] = postfix_config_dir(platform_family)
              postfix[:config_files] = postfix_config_files(platform_family)
              postfix[:current_configuration] = check_configuration
      else
          if find_postfix_executable(platform_family)
            postfix Mash.new
            postfix[:INFO] = "Postfix is not installed from RPM/DEB packages"
          end         
      end      
 end
end