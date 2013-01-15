# Cookbook Name:: racktables
# # Recipe:: default
# #
# # Copyright 2012, BigPoint GmbH
# #
# # All rights reserved - Do Not Redistribute
# #
#

include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "percona::server"

# define some variables

mysql_root_user = "root"
mysql_root_password = node['percona']['server']['root_password']
version = node['racktables']['version']
dbname = node['racktables']['db']['name']
dbuser = node['racktables']['db']['user']
dbhost = node['racktables']['db']['host']
dbpassword = node['racktables']['db']['password']
dbdumpname = node['racktables']['db']['dumpname']
apache_tmp = node['racktables']['vhost']['virtualhost_tmp_path']
racktables_application_path = node['racktables']['path']['application']
racktables_application_user_hash = node['racktables']['application']['password']
apache_conf_path = node['racktables']['path']['apache_conf']
7
if ['debian'].member? node["platform"]

	# Install needed packages

	pkgs = value_for_platform(
		"default" => %w{ php5-gd php5-ldap php5-curl php5-mysql php5-snmp rsync unzip git }
	)

	pkgs.each do |pkg|
		package pkg do
			action :install
		end
	end

	# get racktables and extract it, cleaning up afterwards

	git racktables_application_path do
		repository "git://github.com/RackTables/racktables.git"
		reference "RackTables-#{version}"
		action :sync
	end

	apache_site "default" do
		enable false
	end

	web_app "racktables" do
		template "racktables.conf.erb"
		docroot "#{racktables_application_path}/wwwroot"
		server_name node["racktables"]["vhost"]["servername"]
		server_aliases node["racktables"]["vhost"]["server_aliases"]
	end

	directory "#{apache_tmp}/sessions" do
		owner "www-data"
		group "www-data"
		mode 0755
		action :create
	end

	# all files should be in place now, lets take care of the database

	execute "Create database" do
		command "mysql -p#{mysql_root_password} -NBe 'CREATE DATABASE #{dbname} CHARACTER SET utf8 COLLATE utf8_general_ci;'"
		not_if ("mysql -uroot -p#{mysql_root_password} -NBe 'show databases;' | grep #{dbname}")
	end

	execute "Grant privileges" do
		command "mysql -p#{mysql_root_password} -NBe \"GRANT ALL PRIVILEGES ON #{dbname}.* TO #{dbuser}@localhost IDENTIFIED BY '#{dbpassword}';\""
	end

	# import the mysql data for the current version of racktables

	git "#{Chef::Config[:file_cache_path]}/racktables-contrib" do
		repository "git://github.com/RackTables/racktables-contribs.git"
		reference "master"
		action :sync
	end

	execute "import mysql of current version" do
		command "mysql #{dbname} -p#{mysql_root_password} < #{Chef::Config[:file_cache_path]}/racktables-contrib/init-full-#{version}.sql"
	end

	directory "#{Chef::Config[:file_cache_path]}/racktables-contrib" do
		recursive true
		action :delete
	end

	# Last configuration file and user creation for application

	template "#{racktables_application_path}/wwwroot/inc/secret.php" do
		source "secret.php.erb"
		mode "0666"
	end

end

# vim: set ft=ruby et ts=4 sw=4
