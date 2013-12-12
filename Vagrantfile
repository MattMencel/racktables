# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :racktables1 do |racktables1|
    racktables1.vm.box = "wheezy64" #http://debbuild.bigpoint.net/wheezy64.box
    racktables1.vm.hostname = "racktables1"
    racktables1.vm.network :private_network, ip: "192.168.224.10"
    racktables1.vm.network :forwarded_port, guest: 80, host: 8080
    #racktables1.vm.network :forwarded_port, guest: 443, host: 8443
    racktables1.vm.provision :chef_solo do |chef|
      #chef.log_level = :debug
      chef.encrypted_data_bag_secret_key_path = "test/testing_secret"
      chef.data_bags_path = "test/data_bags"
      chef.roles_path = "test/roles"
      chef.json = {
        'lsb' => {
          'codename' => 'wheezy'
        },
        "apache2" => {
          'default_site_enabled' => false
        },
        "ntp" => {
          "servers" => ["ntp-01.nue.bigpoint.net", "ntp-02.nue.bigpoint.net"]
        },
        "racktables" => {
          "install_allow_from" => ""
          #"redirect_url" => "http://somewhere/over/the/rainbow.html"
        }
      }
      chef.add_recipe "chef-solo-search::default"
      #chef.add_recipe "partial_search::default"
      chef.add_recipe "up2date::default"
      chef.add_recipe "ntp"
      chef.add_recipe "chef-racktables"
      chef.add_role("cmdb")
    end
  end
end
