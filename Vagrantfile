# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "azertys/epiclogger"
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.vm.provision :shell, path: "railsbox/startup.sh", run: "always", privileged: false
    
    config.vm.define 'epiclogger' do |node|
      node.vm.hostname = 'epiclogger.dev'
      node.vm.network :private_network, ip: '192.33.33.33'
      # Forward the Rails server default port to the host
      node.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"], owner: "www-data", group: "www-data"
    end 
end