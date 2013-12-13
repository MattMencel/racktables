name					"chef-racktables"
maintainer				"Bigpoint GmbH"
maintainer_email		"j.tabel@bigpoint.net"
license					"All rights reserved"
description				"Installs racktables DC asset management system"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.1.0"

recipe "chef-racktables", "Installs racktables DC asset management system"

depends					"apache2"
depends					"git"
depends                 'database', ">= 1.5.3"
depends                 'mysql', "= 3.0.12"
depends                 "build-essential"


%w{ debian, ubuntu }.each do |os|
	supports os
end

