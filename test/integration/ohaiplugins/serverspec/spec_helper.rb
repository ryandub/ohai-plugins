require 'serverspec'
require 'pathname'
require 'busser'

# Use Chef's gems to speed things up
chef_gem_path = Dir.glob("/opt/chef/embedded/lib/ruby/gems/*")
chef_gem_path.each do |path|
  gemdirs = Dir.glob("#{path}/gems/*")
  gemdirs = gemdirs.map {|x| x + '/lib'}
  $LOAD_PATH.push(*gemdirs)
end

require 'ohai'

# Setup proper path for sudo environment
path = ENV['PATH'].split(":")
["/sbin", "/usr/sbin", "/usr/local/sbin"].each do |dir|
  if !path.include?(dir)
    path.insert(0, dir)
  end
end
ENV['PATH'] = path.join(":")

PLUGIN_PATH = "/opt/ohai-plugins/plugins"
Ohai::Config[:plugin_path] << PLUGIN_PATH
o = Ohai::System.new
o.all_plugins

OHAI = o.data
