#
# Author:: Jason Gignac (<jasonpgignac@gmail.com>)
#
# Copyright 2014, Rackspace Inc.
# Copyright 2012, Riot Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Original ohai template in https://github.com/opscode-cookbooks/nginx
# by Jamie Winsor (<jamie@vialstudios.com>)

Ohai.plugin(:NginxConfig) do
  provides 'nginx_config'

  def parse_flags(flags)
    prefix = nil
    conf_path = nil

    flags.each do |flag|
      case flag
      when /^--prefix=(.+)$/
        prefix = $1
      when /^--conf-path=(.+)$/
        conf_path = $1
      end
    end

    [prefix, conf_path]
  end

  def get_version
    so = shell_out('nginx -v 2>&1')
    so.stdout.lines.each do |line|
      case line
      when /^nginx version: nginx\/(\d+\.\d+\.\d+)/
        return $1
      end
    end
  end

  def get_configure_arguments
    return @conf_args if @conf_args
    so = shell_out('nginx -V 2>&1')
    so.stdout.lines.each do |line|
      case line
      when /^configure arguments:(.+)/
        # This could be better: I'm splitting on configure arguments which
        # removes them and also adds a blank string at index 0 of the array.
        # This is why we drop index 0 and map to add the '--' prefix back to
        # the configure argument.
        return @conf_args = $1.split(/\s--/).drop(1).map { |ca| "--#{ca}" }
      end
    end
  end

  def get_prefix
    return @prefix if @prefix
    @prefix, @conf_path = parse_flags(get_configure_arguments)
    return @prefix
  end

  def get_conf_path
    return @conf_path if @conf_path
    @prefix, @conf_path = parse_flags(get_configure_arguments)
    return @conf_path
  end

  def execute_nginx(flags = '')
    @v_data ||= {}
    return @v_data[flags] if @v_data[flags]
    status, stdout, stderr = run_command(no_status_check => true,
                                         command => "nginx #{flags}")
    return @v_data[flags] = {
      status: status,
      stdout: stdout,
      stderr: stderr
    }
  end

  def get_vhosts
    r1 = []
    vhosts = {}
    vhosts = {}
    domain = nil
    docroot = nil
    file = File.read(@conf_path)
    begin
      file.each_line do |l|
        if /include/.match(l)
          r1 << l.gsub('include', '').strip.chop if /include/.match(l)
        end
      end
    end
    Dir.glob(r1) do |f|
      f = File.read(f)
      f.each_line do |ll|
        case ll.strip.chop
        when /^#/
          next
        when /^server_name/
          domain = ll.split[1].chomp(';')
        when /^root/
          docroot = ll.split[1].chomp(';')
          else
          next
          end
      end
      unless domain.nil?
        vhosts[domain] = {}
        vhosts[domain]['domain'] = domain
        vhosts[domain]['docroot'] = docroot
      end
    end
    vhosts
  end

  def get_conf_valid
    return execute_nginx('-t')[:status] == 0
  end

  def get_conf_errors
    return execute_nginx('-t')[:stderr] if get_conf_valid
    return ''
  end

  def find_nginx
    so = shell_out("/bin/bash -c 'command -v nginx'")
    nginx_bin = so.stdout.strip
    return nginx_bin unless nginx_bin.empty?
  end

  collect_data(:linux) do
    nginx = find_nginx
    if find_nginx
      nginx_config Mash.new
      nginx_config[:version]             = get_version
      nginx_config[:configure_arguments] = get_configure_arguments
      nginx_config[:prefix]              = get_prefix
      nginx_config[:conf_path]           = get_conf_path
      nginx_config[:includes]            = get_includes
      nginx_config[:vhosts]              = get_vhosts
      nginx_config[:conf_valid]          = get_conf_valid
      nginx_config[:conf_errors]         = get_conf_errors
    end
  end
end
