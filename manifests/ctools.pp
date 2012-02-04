class pentaho::ctools {
  require pentaho::apt_source
  package {
    'ctools':
      ensure   => "latest",
      notify   => Service['bi-server'];
    'libjson-ruby':
      ensure => installed;
  }
}
