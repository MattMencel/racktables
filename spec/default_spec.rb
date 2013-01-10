require 'chefspec'

%w{ debian }.each do |platform|
	describe "The racktables::default #{platform} recipe" do
	before (:all) {
		@chef_run = ChefSpec::ChefRunner.new
		@chef_run.node.automatic_attrs["platform"] = platform
		@chef_run.node.set["lsb"] = { "codename" => "squeeze" }
		@chef_run.node.set["percona"] = { "server" => { "root_password" => "testpwd" } }
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
	it "should donwload racktables.tar.gz file" do
		@chef_run.should create_remote_file '/srv/racktables/racktables.tar.gz'
	end
	it "should extract racktables.tar.gz" do
		@chef_run.should execute_command 'tar xvfz racktables.tar.gz'
	end
	it "should move the extracted folder to /home/racktables" do
		@chef_run.should execute_command 'rsync -Wav --progress racktables-master/* .'
	end
	it "should delete the extracted directory" do
		@chef_run.should delete_directory '/srv/racktables/racktables-master'
	end
	it "should create the vhost config file from template" do
		@chef_run.should create_file '/etc/apache2/sites-available/apache2-racktables.conf'
	end
	it "should disable default vhost and activate racktables vhost" do
		@chef_run.should execute_command 'a2enmod rewrite'
		@chef_run.should execute_command 'a2dissite default'
		@chef_run.should execute_command 'a2ensite apache2-racktables.conf'
	end
	it "should create sessions directory owend by www-data" do
		@chef_run.should create_directory '/tmp/sessions'
		@chef_run.directory('/tmp/sessions').should be_owned_by('www-data', 'www-data')
	end
	it "should create the database and grant db user rights on it" do
		@chef_run.should execute_command "mysql -ptestpwd -NBe 'CREATE DATABASE racktables CHARACTER SET utf8 COLLATE utf8_general_ci;'"
		@chef_run.should execute_command command "mysql -ptestpwd -NBe \"GRANT ALL PRIVILEGES ON racktables.* TO racktablesuser@localhost IDENTIFIED BY 'racktablespwd';\""
	end
	end
end
