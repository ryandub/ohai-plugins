ohai-plugins
==================
This repo contains plugins for Opscode's [Ohai](https://github.com/opscode/ohai) tool. Many of these plugins are provided in a self-contained Ohai package called `ohai-solo`.

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
* Ubuntu 10.10 (Uses 10.04 package)
* Ubuntu 11.04 (Uses 10.04 package)
* Ubuntu 11.10 (Uses 10.04 package)
* Ubuntu 12.04
* Ubuntu 12.10
* Ubuntu 13.04
* Ubuntu 13.10 (Uses 13.04 package)
* Ubuntu 14.04 (Uses 13.04 package)
* CentOS/RHEL 5 (use "el" as platform name)
* CentOS/RHEL 6 (use "el" as platform name)
* Debian 6
* Debian 7

###Installing Ohai-Solo:

```
curl -sSL http://ohai.rax.io/install.sh|bash
ohai-solo
```

###Installing Ohai-Solo (manual):

To use `ohai-solo`, grab the latest package for your distribution by querying the list of packages (this example uses [HTTPie](https://github.com/jkbr/httpie) - if you don't have it, you should):

```
http http://ohai.rax.io/packages.json
...

    "ohai-solo_1.0.5-1.ubuntu.12.04_amd64.deb": {
        "arch": "x86_64",
        "basename": "ohai-solo_1.0.5-1.ubuntu.12.04_amd64.deb",
        "last_modified": "2014-01-03T16:54:52",
        "md5": "ebc323c06e7645ec7a3a159617cd1b7b",
        "platform": "ubuntu",
        "platform_version": "12.04",
        "sha256": "2f62e94ca7bf7155280f18e32fa072953941a055bcbbfcc13022ea2cb48fc96b",
        "version": "1.0.5"
    },
 ...

```

You can also request the latest package for your distribution by querying `http://ohai.rax.io/latest.<platform>.<platform_version>.<arch>.json`. For example:

* Ubuntu 12.04 64-bit:

```
http http://ohai.rax.io/latest.ubuntu.12.04.x86_64.json
...

{
    "arch": "x86_64",
    "basename": "ohai-solo_1.0.5-1.ubuntu.12.04_amd64.deb",
    "last_modified": "2014-01-03T16:55:04",
    "md5": "ebc323c06e7645ec7a3a159617cd1b7b",
    "platform": "ubuntu",
    "platform_version": "12.04",
    "sha256": "2f62e94ca7bf7155280f18e32fa072953941a055bcbbfcc13022ea2cb48fc96b",
    "version": "1.0.5"
}
```

* CentOS/RHEL 6 64-bit:

```
http http://ohai.rax.io/latest.el.6.x86_64.json
...
{
    "arch": "x86_64",
    "basename": "ohai-solo-1.0.3-1.el6.x86_64.rpm",
    "last_modified": "2014-01-03T16:53:57",
    "md5": "c3a864c198defe4dcb9c1995876ded65",
    "platform": "el",
    "platform_version": "6.4",
    "sha256": "6fffad237f58bbd567785d9c97c3228babb01bd387d53c397d63a0937d0a5611",
    "version": "1.0.3"
}
```

Once you have your package name, download and install it using the `basename` returned from the API:

```
wget http://ohai.rax.io/ohai-solo_1.0.5-1.ubuntu.12.04_amd64.deb
dpkg -i ohai-solo_1.0.5-1.ubuntu.12.04_amd64.deb
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
bundle 

You can now test all OSs with:
```
bundle exec kitchen test
```
or just one with for example:
```
bundle exec kitchen test ohaiplugins-centos-6
```
check the possible OS types with:
```
bundle exec kitchen list
```
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
