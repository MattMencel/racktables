include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_ssl"
include_recipe "percona::server"

# define some variables

mysql_root_user = "root"
mysql_root_password = node[:percona][:server][:root_password]
version = node[:racktables][:version]
dbname = node[:racktables][:db][:name]
dbuser = node[:racktables][:db][:user]
dbhost = node[:racktables][:db][:host]
dbpassword = node[:racktables][:db][:password]
dbdumpname = node[:racktables][:db][:dumpname]
server_aliases = node[:racktables][:server_aliases]
racktables_application_path = node[:racktables][:path][:application]
racktables_application_user_hash = node[:racktables][:application][:password]
virtualhost_log_path = "/var/log/apache2"
virtualhost_tmp_path = "/tmp"
virtualhost_public_path = "#{racktables_application_path}/wwwroot"
php_include_path = node[:racktables][:php_include_path]
apache_conf_path = node[:racktables][:path][:apache_conf]

if ['debian'].member? node["platform"]

	# Install needed packages

	pkgs = value_for_platform(
		"default" => %w{ php5-gd php5-ldap php5-curl php5-mysql php5-snmp rsync unzip }
	)

	pkgs.each do |pkg|
		package pkg do
			action :install
		end
	end

	# get racktables and extract it, cleaning up afterwards

	directory "#{racktables_application_path}" do
		recursive true
		owner "root"
		group "root"
		mode 0755
		action :create
		not_if do File.directory?("#{racktables_application_path}") end
	end

	remote_file "#{racktables_application_path}/racktables.tar.gz" do
		source "https://github.com/RackTables/racktables/archive/master.tar.gz"
		owner "root"
		group "root"
	end
	execute "extract racktables.tar.gz" do
		cwd racktables_application_path 
		user "root"
		command "tar xvfz racktables.tar.gz"
		action :run
	end
	execute "move racktables" do
		cwd racktables_application_path
		command "rsync -Wav --progress racktables-master/* ."
		action :run
	end
	file "#{racktables_application_path}/racktables.tar.gz" do
		action:delete
		only_if do ::File.exists?("#{racktables_application_path}/racktables.tar.gz") end
	end
	directory "#{racktables_application_path}/racktables-master" do
		recursive true
		action:delete
		only_if do ::File.directory?("#{racktables_application_path}/racktables-master") end
	end

	# take care of apache vhost configuration

	template "#{apache_conf_path}/apache2-racktables.conf" do
		source "apache2-racktables.conf.erb"
		mode "0644"
		variables(
			:document_root => virtualhost_public_path,
			:virtualhost_log_path => virtualhost_log_path,
			:virtualhost_tmp_path => virtualhost_tmp_path,
			:php_include_path => php_include_path,
			:server_aliases => server_aliases
		)
	end

	execute "Enable apache rewrite" do
		command "a2enmod rewrite"
	end

	execute "Disable apache default" do
		command "a2dissite default"
	end

	execute "Enable racktables" do
		command "a2ensite apache2-racktables.conf"
	end

	directory "/tmp/sessions" do
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

	remote_file "/tmp/racktables-contrib.zip" do
		source "https://github.com/RackTables/racktables-contribs/archive/master.zip"
		owner "root"
		group "root"
	end

	execute "extract racktables-contrib.zip" do
		cwd "/tmp"
		user "root"
		command "unzip -u racktables-contrib.zip"
		action :run
	end

	execute "import mysql of current version" do
		command "mysql #{dbname} -p#{mysql_root_password} < /tmp/racktables-contribs-master/init-full-#{version}.sql"
	end

	# Last configuration file and user creation for application

	template "#{racktables_application_path}/wwwroot/inc/secret.php" do
		source "secret.php.erb"
		mode "0666"
	end

#	execute "create racktables user" do
#		command "mysql #{dbname} -p#{mysql_root_password} -NBe \"INSERT INTO UserAccount (user_id, user_name, user_password_hash, user_realname) VALUES (1,'admin','#{racktables_application_user_hash}','RackTables Administrator');\""
#	end
end

# vim: set ft=ruby et ts=4 sw=4
