name             'ohai_plugins_test'
maintainer       'Rackspace Hosting'
maintainer_email 'ryan.walker@rackspace.com'
license          'Apache 2.0'
description      'Cookbook to prepare for testing Ohai plugins'
#long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

depends 'apache2'
depends 'build-essential'
depends 'git'
depends 'hostsfile'
depends 'nginx'
depends 'wordpress'
