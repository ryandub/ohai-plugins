# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "ohai-plugins-vagrant"
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :private_network, ip: "33.33.33.10"
  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.vm.provision :shell, :inline => "apt-get -y install curl;\
    FILE=`curl -s http://ohai.rax.io/latest.ubuntu.12.04.x86_64.json\
    |python -mjson.tool|grep basename\
    |awk '{print $2}'|sed 's/[\"|\,]//g'`;\
    wget http://ohai.rax.io/$FILE -O /tmp/$FILE;\
    dpkg -i /tmp/$FILE;echo -e '\n\n Run ohai-solo -d /vagrant/plugins to test plugins'"
end
