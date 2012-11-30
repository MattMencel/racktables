include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "percona::server"

if ['debian'].member? node["platform"]


	pkgs = value_for_platform(
		"default" => %w{ php5-gd php5-ldap php5-curl php5-mysql php5-snmp }
	)

	pkgs.each do |pkg|
		package pkg do
			action :install
		end
	end
	remote_file "/home/racktables.tar.gz" do
		source "https://github.com/RackTables/racktables/archive/master.tar.gz"
		owner "root"
		group "root"
	end
	bash "extract_racktables" do
		user "root" 
		cwd "/home"
		code <<-EOH
		tar xvfz racktables.tar.gz
		mv racktables-master racktables
		EOH
	end
	directory "/var/www" do
		recursive true
		action :delete
	end
	link "/var/www" do
		to "/home/racktables/wwwroot"
		not_if do ::File.symlink?("/var/www") end
	end
end

# vim: set ft=ruby et ts=4 sw=4
