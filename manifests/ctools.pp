class pentaho::ctools {
  include pentaho::apt_source
  package { "ctools":
    ensure   => "latest",
    notify   => Service['bi-server'],
  }
}
