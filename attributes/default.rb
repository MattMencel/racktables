default["racktables"]["version"] = "0.20.5"
default["racktables"]["db"]["host"] = "localhost"
default["racktables"]["db"]["name"] = "racktables"
default["racktables"]["db"]["user"] = "racktablesuser"
default["racktables"]["db"]["password"] = "racktablespwd"
default["racktables"]["application"]["password"] = "4015bc9ee91e437d90df83fb64fbbe312d9c9f05"
default["racktables"]["path"]["apache_conf"] = "/etc/apache2/sites-available"
default["racktables"]["path"]["application"] = "/srv/racktables"
default["racktables"]["vhost"]["servername"] = "localhost"
default["racktables"]["vhost"]["server_aliases"] = [ "127.0.0.1", "localhost" ]
default["racktables"]["vhost"]["virtualhost_log_path"] = "/var/log/apache2"
default["racktables"]["vhost"]["virtualhost_tmp_path"] = Chef::Config[:file_cache_path]
default["racktables"]["vhost"]["php_include_path"] = [ ".","/usr/share/php","/usr/share/pear" ]

