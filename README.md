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

Recipes
=======

Currently there is only a default recipe, that installs the Webserver and database on the same host. After that, the current master-branch from racktables github is downloaded and extracted. Also some additional packages are installed, mostly php5 modules.
