class pentaho::biserver {
  file { "pentaho-bi-server_3.10.0_all.deb":
    path   => "/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb",
    source => "puppet:///modules/pentaho/pentaho-bi-server_3.10.0_all.deb",
  }

  package { "openjdk-6-jre":
    ensure => latest,
  }

	package { "pentaho-bi-server":
		ensure   => "present",
    provider => "dpkg",
		source   => "/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb",
    require  => [File["pentaho-bi-server_3.10.0_all.deb"], Package["openjdk-6-jre"]],
	}

  $tomcat_port = "8080"
  file {
    "/opt/pentaho/biserver-ce/tomcat/conf/server.xml":
      require => Package["pentaho-bi-server"],
      content  => template("pentaho/tomcat/conf/server.xml");
  }
}

class pentaho::saiku {
  file { "saiku-plugin_2.2-SNAPSHOT-20111201_all.deb":
    path   => "/var/cache/apt/archives/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
    source => "puppet:///modules/pentaho/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
  }

	package { "saiku-plugin":
		ensure   => "present",
    provider => "dpkg",
		source   => "/var/cache/apt/archives/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
    require  => [File["saiku-plugin_2.2-SNAPSHOT-20111201_all.deb"], Class["pentaho::biserver"]],
	}
}
