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
* node["racktables"]["php_include_path"] - include path for php files
* node["racktables"]["server_aliases"] - Array holding the server aliases for the vhost conf. Default is ["127.0.0.1", "localhost"]

Recipes
=======

Currently there is only a default recipe, that installs the Webserver and database on the same host. After that, the current master-branch from racktables github is downloaded and extracted. Also some additional packages are installed, mostly php5 modules. Installation is fully automated, no webinstaller needed.
