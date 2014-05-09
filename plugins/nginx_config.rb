#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
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

Ohai.plugin(:NginxConfig) do
  provides "nginx_config"
  provides "nginx_config/version"
  provides "nginx_config/configure_arguments"
  provides "nginx_config/prefix"
  provides "nginx_config/conf_path"

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

    [ prefix, conf_path ]
  end

  nginx_config = Mash.new
  nginx_config[:version]             = nil unless nginx_config[:version]
  nginx_config[:configure_arguments] = Array.new unless nginx_config[:configure_arguments]
  nginx_config[:prefix]              = nil unless nginx_config[:prefix]
  nginx_config[:conf_path]           = nil unless nginx_config[:conf_path]

  status, stdout, stderr = run_command(:no_status_check => true, :command => "nginx -V")

  if status == 0
    stderr.split("\n").each do |line|
      case line
      when /^configure arguments:(.+)/
        # This could be better: I'm splitting on configure arguments which removes them and also
        # adds a blank string at index 0 of the array. This is why we drop index 0 and map to
        # add the '--' prefix back to the configure argument.
        nginx_config[:configure_arguments] = $1.split(/\s--/).drop(1).map { |ca| "--#{ca}" }

        prefix, conf_path = parse_flags(nginx_config[:configure_arguments])

        nginx_config[:prefix] = prefix
        nginx_config[:conf_path] = conf_path
      when /^nginx version: nginx\/(\d+\.\d+\.\d+)/
        nginx_config[:version] = $1
      end
    end
    status, stdout, stderr = run_command(:no_status_check => true, :command => "nginx -t")
    if status == 0
      nginx_config[:conf_valid] = true
    else
      nginx_config[:conf_valid] = false
      nginx_config[:conf_errors] = stderr
    end
    puts "Start..."
    puts "Stdout: #{stdout}"
    puts "Stderr: #{stderr}"
    puts "Status: #{status == 0}"
    puts "End!"
  end
end