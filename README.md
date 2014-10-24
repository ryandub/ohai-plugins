ohai-plugins
==================
This repo contains plugins for Opscode's [Ohai](https://github.com/opscode/ohai) tool. Many of these plugins are provided in a self-contained Ohai package called `ohai-solo`.

![](https://travis-ci.org/rackerlabs/ohai-plugins.svg?branch=master)

##Writing Ohai Plugins
####Using Vagrant
Using [Vagrant](http://www.vagrantup.com/), you can easily create new/modify `Ohai` plugins in the `/plugins` directory and test them on an Ubuntu 12.04 system.


```
vagrant up
vagrant ssh
/opt/ohai-solo/bin/ohai -d /vagrant/plugins
```

This command runs `Ohai` and tells it to use the plugins located in this repo.


## Ohai-Solo
Ohai-Solo is a package that contains an embedded version of Ruby 1.9.3, Ohai, and the plugins from this repo. Packages are built using Opscode's [Omnibus](https://github.com/opscode/omnibus-ruby) system. You can find the Omnibus build environment for Ohai-Solo [here](https://github.com/ryandub/omnibus-ohai-solo).

Packages are currently provided/tested for these distributions:

* Ubuntu 10.04
* Ubuntu 10.10
* Ubuntu 11.04
* Ubuntu 11.10
* Ubuntu 12.04
* Ubuntu 12.10
* Ubuntu 13.04
* Ubuntu 13.10
* Ubuntu 14.04
* CentOS/RHEL 5
* CentOS/RHEL 6
* Debian 6
* Debian 7

###Installing Ohai-Solo:

```
curl -sSL http://ohai.rax.io/install.sh|bash
```

This will install `ohai-solo` to `/opt/ohai-solo`. Simply run `ohai-solo` to get all output.

###Contributing:
If you would like to contribute an Ohai plugin to this project, add the plugin
to the `plugins` directory. Create a [serverspec](https://github.com/serverspec/serverspec)
test in `test/integration/ohaiplugins/serverspec/localhost/` that tests your
plugin, named like `pluginname_spec.rb`.

If the Ohai plugin needs the O/S to be in a non-default state, create or
reference a Chef recipe. Either modify `Berksfile` to refer to a third party
recipe, or create one under `cookbooks/ohai_plugins_test/recipes/` to configure
the test environment for your plugin (e.g. install packages, modify config
files). Reference the Chef recipe for either all O/S types, or just specific
ones in `.kitchen.yml` and `.kitchen.rackspace.yml`, e.g.:
```
run_list:
- recipe[apache2]                    <- for those referenced in Berksfile
- recipe[ohai_plugins_test::rhcs]    <- for those created locally
```
You'll need to reference your forked ohai-plugins git repo and branch in
`cookbooks/ohai_plugins_test/attributes/default.rb` as this is pulled into the
test environments.

Install bundler and then run:
```
bundle install
```
To check style errors with Rubocop run:
```
bundle exec rake style
```
To test all OS's run:
```
bundle exec kitchen test
```
or just one with:
```
bundle exec kitchen test centos-6
```
List the possible OS types with:
```
bundle exec kitchen list
```
Test multiple OS's in parallel:
```
bundle exec kitchen test -p 3
```
This can be very resource intensive unless you are using the
 `kitchen-rackspace` provider. More info about `kitchen-rackspace` below.

If a test fails, you can delete the test environment with for example:
```
bundle exec kitchen destroy ohaiplugins-centos-6
```
There is a provided `.kitchen.rackspace.yml` file if you prefer to use Rackspace
cloud Servers for testing instead of Vagrant. To use Rackspace cloud servers
copy `.kitchen.rackspace.yml` to `.kitchen.local.yml` and provide the
environment variables:
```
export RS_USERNAME=<username>
export RS_APIKEY=<apikey>
export SSH_KEY_FILE=/root/.ssh/id_rsa.pub
export RS_FLAVOR=performance1-1
export RS_REGION=lon,dfw,ord,iad,syd,hkg
```

For time purposes, it is recommended while developing to test one OS in order
 to validate your code. Once you have all the big hurdles out of the way, move
 to testing across all OS's.
