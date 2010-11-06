class powerdns::contents {
	$pdns_server_pkg = $os ? {
		debian => "pdns-server",
		gentoo => "pdns",
		default => "pdns",
	}

	case $os {
		centos: {}
		Debian: {
			package { "pdns-backend-mysql": 
				ensure => installed 
			}
		}
		Default: {
		    	package { $pdns_server_pkg:
				ensure => installed 
			}
		}
	}
}

define powerdns::contents::create($db_host = "127.0.0.1", $db_user = "pdns", $db_name = "pdns", $recursor = false, $bind_v4 = false, $bind_v6 = false, $axfr_ips = false, $db_password = false) {
	case $name {
		"pdns": {
			service { "pdns":
				ensure => running,
				enable => true, 
				require => Service["mysql"]
			}

			file { "/etc/powerdns/pdns.conf":
				content => template("etc/powerdns/pdns.conf"),
				notify => Service["pdns"],
			}

		}
		default: {
			file { "/etc/init.d/pdns.${name}":
				ensure => link,
				target => "/etc/init.d/pdns"
			}

			service { "pdns.${name}":
				ensure => running,
				enable => true, 
				require => Service["mysql"],
				pattern => "/usr/sbin/pdns_server-${name}-instance",
			}

			file { "/etc/powerdns/pdns-${name}.conf":
				content => template("etc/powerdns/pdns.conf"),
				notify => Service["mysql"],
			}
		}
	}
}

class powerdns::poweradmin {
	case $os {
		Gentoo: {
			package { "PEAR-MDB2_Driver_mysql":
				category => "dev-php",
				ensure => installed
			}
		}
	}
}
