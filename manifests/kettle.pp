class pentaho::kettle {
  include pentaho::java
  file { 'pentaho-kettle_4.2.0_all.deb':
    path   => '/var/cache/apt/archives/pentaho-kettle_4.2.0_all.deb',
    source => 'puppet:///modules/pentaho/pentaho-kettle_4.2.0_all.deb',
  }

  package { "pentaho-kettle":
    ensure  => "present",
    provider => "dpkg",
    source  => '/var/cache/apt/archives/pentaho-kettle_4.2.0_all.deb',
    require => File['pentaho-kettle_4.2.0_all.deb'],
  }

}
