class pentaho::saiku {
  include pentaho::apt_source
  package { "saiku-plugin":
    ensure  => "latest",
  }
}

