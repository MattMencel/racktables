# Encoding: UTF-8
# Cookbook Name:: chef-racktables
# Description:: Bigpoint racktables database
# Recipe:: db
# Author:: Julian Tabel (<j.tabel@bigpoint.net>)

wrong_cfg = '/etc/my.cnf' # will be removed if existing
version = node['racktables']['version']
racktables_application_path = node['racktables']['path']['application']

# MySQL/Percona
db_cred = Chef::EncryptedDataBagItem.load('racktables', 'mysql')

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
node.set['mysql']['server_root_password'] = db_cred['root']
node.set['mysql']['server_debian_password'] = db_cred['debian']
node.set['mysql']['server_repl_password'] = db_cred['replication']

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
                          :password => db_cred['root'] }

cred = Chef::EncryptedDataBagItem.load('racktables', 'db')

mysql_database cred['dbname'] do
  connection mysql_connection_info
  action :create
end

mysql_database_user cred['username'] do
  connection mysql_connection_info
  password cred['password']
  action :create
end

mysql_database_user cred['username'] do
  connection mysql_connection_info
  password cred['password']
  database_name cred['dbname']
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

mysql_database cred['dbname'] do
    connection mysql_connection_info
    sql { ::File.open("/tmp/racktables-contrib/demo.racktables.org/init-full-#{version}.sql").read }
    action :query
end

template "#{racktables_application_path}/wwwroot/inc/secret.php" do
    source "secret.php.erb"
    mode "0400"
    owner node['apache']['user']
    group node['apache']['group']
    variables({ 'dbname' => cred['dbname'],
                'dbuser' => cred['username'],
                'dbpass' => cred['password']
    })
end

#directory "#{Chef::Config[:file_cache_path]}/racktables-contrib" do
#    recursive true
#    action :delete
#end
