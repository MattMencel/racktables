require 'chefspec'

%w{ debian }.each do |platform|
	describe "The racktables::default #{platform} recipe" do
	before (:all) {
		@chef_run = ChefSpec::ChefRunner.new
		@chef_run.node.automatic_attrs["platform"] = platform
		@chef_run.node.set["lsb"] => { "codename" => "squeeze" }
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
		@chef_run.should create_remote_file '/home/racktables.tar.gz'
	end
	it "should extract racktables.tar.gz" do
		@chef_run.should execute_command 'tar xvfz racktables.tar.gz'
	end
	it "should move the extracted folder to /home/racktables" do
		@chef_run.should execute_command 'mv /home/racktables-master /home/racktables'
	end
	it "should have home/racktables/wwwroot there to create symlink" do
		File.should exist("/home/racktables/wwwroot")
	end
	it "should delete /var/www" do
		@chef_run.should delete_directory '/var/www'
	end
	it "should link /home/racktables/wwwroot to /var/www" do
		@chef_run.should create_link "/var/www"
	end
	end
end
