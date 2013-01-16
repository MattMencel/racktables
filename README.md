Description
===========

This cookbook provides a full installation of racktables, a datacenter asset management system. It installs apache2, including mod_php5 and mod_ssl, as well as mysql percona as database backend. 

Requirements
============

## Cookbooks:

The following cookbooks are required for installing racktables:

* apache2
* percona

## Platforms:

Currently, racktables cookbook is only tested on Debian, but should run fine on Ubuntu as well.

## Attributes

* node["racktables"]["version"] - setting version of racktables, that should be installed. Defaults to 0.20.3
* node["racktables"]["db"]["host"] - DB Host for racktables MySQL DB. Defaults to localhost
* node["racktables"]["db"]["name"] - Name of the racktables DB. Defaults to racktables
* node["racktables"]["db"]["user"] - User for the DB. Defaults to racktables_user
* node["racktables"]["db"]["password"]  - - Database Password for MySQL. Defaults to racktablespwd
* node["racktables"]["application"]["password"] - Password for admin user. Defaults to admin-hash
* node["racktables"]["path"]["apache_conf"] - Path to vhost-conf. Defaults to /etc/apache2/sites-available
* node["racktables"]["path"]["application"] - Path to application. Defaults to /srv/racktables
* node["racktables"]["vhost"]["servername"] - FQDN for server, defaults to localhost
* node["racktables"]["vhost"]["server_aliases"] - Array holding the server aliases for the vhost conf. Default is ["127.0.0.1", "localhost"]
* node["racktables"]["vhost"]["virtualhost_log_path"] - Path for logfiles from apache for this vhost. Defaults to /var/log/apache2
* node["racktables"]["vhost"]["virtualhost_tmp_path"] - Path for temporary files Defaults to Chef::Config[:file_cache_path]
* node["racktables"]["vhost"]["php_include_path"] - Include Path for PHP. Defaults to ".","/usr/share/php","/usr/share/pear"

Recipes
=======

Currently there is only a default recipe, that installs the Webserver and database on the same host. After that, the current master-branch from racktables github is downloaded and extracted. Also some additional packages are installed, mostly php5 modules. Installation is fully automated, no webinstaller needed.

Usage
=====

After succesfull chef run, racktables is accessable via any webbrowser. To login, you need the standard user admin with the password being the same as the username. For further documentation, please have a look at:

 * http://www.racktables.org

Vagrantfile
===========

Please ensure you have port 80 forwarded to access the WebUI, anything else is not required.

# Example Vagrantfile

This Vagrantfile is used during testing the cookbook:

```
#vi: set ft=ruby ts=4 sw=4 :

# Vagrant File for racktables test setup

Vagrant::Config.run do |config|

	# Definition of the apache web service machine

	config.vm.define :squeeze64 do |squeeze64|
		squeeze64.vm.box = "squeeze-64"
		squeeze64.vm.box_url = "http://debbuild.bigpoint.net/squeeze64.box"
		squeeze64.vm.host_name = "squeeze64"
		squeeze64.vm.network :hostonly, "192.168.1.10"
		squeeze64.vm.forward_port 80, 1234
		squeeze64.vm.provision :chef_solo do |chef|
			chef.node_name = "squeeze64"
			chef.cookbooks_path = ["cookbooks"]
			chef.add_recipe ("apt")
			chef.add_recipe ("racktables")
			chef.json = {
				# MySQL settings for percona cookbook
				'percona' => { 'server' => { 'root_password' => 'vagrant_root_password', 'debian_password' => 'vagrant_debian_password' } },
				'racktables' => { 'vhost' => {'servername' => 'racktables.bigpoint.net' } }
			}
			chef.log_level = :debug
		end
	end
end
```

ToDo
====

* adding possibility to set UserPW in recipe
* adding ssl-vhost conf as an option

License and Author
==================

Author:: Julian Tabel <jtabel@bigpoint.net>

Copyright 2013, BigPoint GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

