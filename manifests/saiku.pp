class pentaho::saiku {
  file { "saiku-plugin_2.2-SNAPSHOT-20111201_all.deb":
   path   => "/var/cache/apt/archives/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
   source => "puppet:///modules/pentaho/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
  }

  package { "saiku-plugin":
    ensure  => "present",
    provider => "dpkg",
    source  => "/var/cache/apt/archives/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
    require  => [File["saiku-plugin_2.2-SNAPSHOT-20111201_all.deb"], Class["pentaho::biserver"]],
  }
}

