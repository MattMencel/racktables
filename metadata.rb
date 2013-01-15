name					"racktables"
maintainer				"Bigpoint GmbH"
maintainer_email		"jtabel@bigpoint.net"
license					"All rights reserved"
description				"Installs racktables DC asset management system"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.6"

recipe "racktables", "Installs racktables DC asset management system"

depends					"apache2"
depends					"percona"

%w{ debian }.each do |os|
	supports os
end

