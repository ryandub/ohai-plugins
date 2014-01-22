# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "ohai-plugins-vagrant"
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.provision :shell, :inline => "wget http://ohai.rax.io/install.sh -O /tmp/install.sh;\
    bash /tmp/install.sh;\
    echo -e '\n\n Run /opt/ohai-solo/bin/ohai -d /vagrant/plugins to test plugins'"
end
