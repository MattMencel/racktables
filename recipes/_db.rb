# Encoding: UTF-8
# Cookbook Name:: chef-racktables
# Description:: Bigpoint racktables database
# Recipe:: db
# Author:: Julian Tabel (<j.tabel@bigpoint.net>)

wrong_cfg = '/etc/my.cnf' # will be removed if existing
version = node['racktables']['version']
racktables_application_path = node['racktables']['path']['application']

# MySQL/Percona
mysql_cred = Chef::EncryptedDataBagItem.load('racktables', 'mysql')

begin
  require 'mysql'
rescue LoadError
  package 'libmysqlclient-dev' do
    action :install
  end
  resources('package[libmysqlclient-dev]').run_action(:install)
  chef_gem 'mysql'
end

node.set['mysql']['server']['packages'] = %w{percona-server-server-5.5}
node.set['mysql']['client']['packages'] = %w{percona-server-client-5.5
libmysqlclient18-dev
ruby-mysql}
node.set['mysql']['tunable']['innodb_file_per_table'] = true
node.set['mysql']['server_root_password'] = mysql_cred['root']
node.set['mysql']['server_debian_password'] = mysql_cred['debian']
node.set['mysql']['server_repl_password'] = mysql_cred['replication']

include_recipe 'mysql::percona_repo'
include_recipe 'mysql::ruby'
include_recipe 'mysql::server'
include_recipe 'mysql::client'
include_recipe 'database::default'

if node['percona']['main_config_file'] != wrong_cfg
  file wrong_cfg do
    action :delete
    only_if { File.exists?(wrong_cfg) }
  end
end

mysql_connection_info = { :host => 'localhost',
                          :username => 'root',
                          :password => mysql_cred['root'] }

db_cred = Chef::EncryptedDataBagItem.load('racktables', 'db')

mysql_database db_cred['dbname'] do
  connection mysql_connection_info
  action :create
end

mysql_database_user db_cred['username'] do
  connection mysql_connection_info
  password db_cred['password']
  action :create
end

mysql_database_user db_cred['username'] do
  connection mysql_connection_info
  password db_cred['password']
  database_name db_cred['dbname']
  host 'localhost'
  privileges ['select', 'lock tables', 'insert', 'update', 'delete',
              'create', 'drop', 'index', 'alter']
  action :grant
end

# racktables-contrib allways has the mysql for the last stable version and many others
# we need this to import the necessary data
git "/tmp/racktables-contrib" do
    repository "http://github.com/RackTables/racktables-contribs"
    reference "master"
    action :sync
end

mysql_database db_cred['dbname'] do
    connection mysql_connection_info
    sql { ::File.open("/tmp/racktables-contrib/demo.racktables.org/init-full-#{version}.sql").read }
    action :query
end

template "#{racktables_application_path}/wwwroot/inc/secret.php" do
    source "secret.php.erb"
    mode "0400"
    owner node['apache']['user']
    group node['apache']['group']
    variables({ 'dbname' => db_cred['dbname'],
                'dbuser' => db_cred['username'],
                'dbpass' => db_cred['password']
    })
end

app_cred = Chef::EncryptedDataBagItem.load('racktables', 'app')

directory "#{Chef::Config[:file_cache_path]}/racktables-contrib" do
    recursive true
    action :delete
end

mysql_database db_cred['dbname'] do
    connection mysql_connection_info
    sql "UPDATE `UserAccount` SET user_password_hash = SHA1('#{app_cred['password']}') WHERE user_id=1"
    action :query
    # retries to wait for initial dump of db
    retries 5
    retry_delay 5
end
