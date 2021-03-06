require 'chefspec'

%w{ debian }.each do |platform|
	describe "The racktables::default #{platform} recipe" do
		before (:all) {
			@chef_run = ChefSpec::ChefRunner.new
			@chef_run.node.automatic_attrs["platform"] = platform
			@chef_run.node.set["lsb"] = { "codename" => "squeeze" }
			@chef_run.node.set["percona"] = { "server" => { "root_password" => "testpwd" } }
			@chef_run.node.set["racktables"] = { "path" => { "application" => "/srv/racktables" } }
			@chef_run.node.set["racktables"] = { "version" => "0.20.5" }
			@chef_run.node.set["racktables"] = { "db" => { "name" => "racktables" } }
			@chef_run.converge 'racktables::default'
		}
		case platform
		when "debian"
			# check, that all packages are installed
			%w{ php5-gd php5-ldap php5-curl php5-mysql php5-snmp }.each do |pkg|
				it "should install #{pkg}" do
					@chef_run.should install_package pkg
				end
			end
		end
		it "should create sessions directory owend by www-data" do
			@chef_run.should create_directory "#{Chef::Config[:file_cache_path]}/sessions"
			@chef_run.directory("#{Chef::Config[:file_cache_path]}/sessions").should be_owned_by('www-data', 'www-data')
		end
		it "should create the database and grant db user rights on it" do
			@chef_run.should execute_command "mysql -ptestpwd -NBe 'CREATE DATABASE racktables CHARACTER SET utf8 COLLATE utf8_general_ci;'"
			@chef_run.should execute_command "mysql -ptestpwd -NBe \"GRANT ALL PRIVILEGES ON racktables.* TO racktablesuser@localhost IDENTIFIED BY 'racktablespwd';\""
		end
#		it "should import the mysql from sql file" do
#			@chef_run.should execute_command "mysql racktables -ptestpwd < #{Chef::Config[:file_cache_path]}/racktables-contrib/demos.racktables.org/init-full-{@chef_run.node['racktables']['version']}.sql"
#		end
		it "should create secret.php" do
			@chef_run.should create_file "/srv/racktables/wwwroot/inc/secret.php"
		end
	end
end
