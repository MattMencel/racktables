# Encoding: UTF-8
# Cookbook Name:: chef-racktables
# Description:: Bigpoint racktables 
# Recipe:: default
# Author:: Julian Tabel (<j.tabel@bigpoint.net>)

# These cookbooks are required by the racktables default cookbook

include_recipe "git"
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
# include_recipe "chef-racktables::_db"

# define some variables

version = node['racktables']['version']
apache_tmp = node['racktables']['vhost']['virtualhost_tmp_path'] 
racktables_application_path = node['racktables']['path']['application']
racktables_application_user_hash = node['racktables']['application']['password']
apache_conf_path = node['racktables']['path']['apache_conf']

# currently only tested on debian, so only doing something for it

if ['debian','ubuntu'].member? node["platform"]

	# Install needed packages

	pkgs = value_for_platform(
		"default" => %w{ php5-gd php5-ldap php5-curl php5-mysql php5-snmp }
	)
	pkgs.each do |pkg|
		package pkg do
			action :install
		end
	end

	# get desired version of racktables from git and put it to the application path

	git racktables_application_path do
		repository "http://github.com/RackTables/racktables"
		reference "RackTables-#{version}"
		action :sync
	end

	# disable the default apache vhost. we know it works

	apache_site "default" do
		enable false
	end

	# we need a new vhost for racktables
	# using the web_app definition from apache for convenience

	web_app "racktables" do
		template "racktables.conf.erb"
		docroot "#{racktables_application_path}/wwwroot"
		server_name node["racktables"]["vhost"]["servername"]
		server_aliases node["racktables"]["vhost"]["server_aliases"]
	end

	# sessions are stored in files 
	# directory needs to be created for www-data before using racktables
	directory "#{apache_tmp}/sessions" do
		owner "www-data"
		group "www-data"
		mode 0755
		action :create
	end

    include_recipe "chef-racktables::_db"

end

# vim: set ft=ruby et ts=4 sw=4
