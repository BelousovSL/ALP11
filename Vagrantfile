# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'
Vagrant.configure("2") do |config|
    config.vm.define "belousovBash" do |belousovBash|
        belousovBash.vm.box = "bento/ubuntu-24.04"                      
        belousovBash.vm.host_name = "belousovBash"
        belousovBash.vm.synced_folder "scripts/", "/root/scripts"
        belousovBash.vm.synced_folder "mails/", "/root/mails"
        belousovBash.vm.provision "shell", path: "init.sh"
        belousovBash.vm.provider "virtualbox" do |vb|
         vb.memory = "1024"
         vb.cpus = "2"
       end 
    end
 end

 # https://linuxconfig.org/configuring-gmail-as-sendmail-email-relay