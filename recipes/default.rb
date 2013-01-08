include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_ssl"
include_recipe "percona::server"

if ['debian'].member? node["platform"]


	pkgs = value_for_platform(
		"default" => %w{ php5-gd php5-ldap php5-curl php5-mysql php5-snmp rsync }
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
		cp -vrf racktables-master/* racktables/
		EOH
	end
	file "/home/racktables.tar.gz" do
		action:delete
		only_if do ::File.exists?("/home/racktables.tar.gz") end
	end
	directory "/home/racktables-master" do
		recursive true
		action:delete
		only_if do ::File.directory?("/home/racktables-master") end
	end
	directory "/var/www" do
		recursive true
		action :delete
		only_if do ::File.directory?("/var/www") end
	end
	link "/var/www" do
		to "/home/racktables/wwwroot"
		not_if do ::File.symlink?("/var/www") end
	end
end

# vim: set ft=ruby et ts=4 sw=4
