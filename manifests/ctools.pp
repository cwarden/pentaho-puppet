class pentaho::ctools {
  file { "ctools_20111219_all.deb":
   path   => "/var/cache/apt/archives/ctools_20111219_all.deb",
   source => "puppet:///modules/pentaho/ctools_20111219_all.deb",
  }

  package { "ctools":
    ensure   => "latest",
    provider => "dpkg",
    source   => "/var/cache/apt/archives/ctools_20111219_all.deb",
    require  => [File["ctools_20111219_all.deb"], Class["pentaho::biserver"]],
    notify   => Service['bi-server'],
  }
}


