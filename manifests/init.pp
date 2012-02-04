Class['pentaho::biserver'] -> Class['pentaho::config']
Class['pentaho::biserver'] -> Class['pentaho::saiku']
Class['pentaho::biserver'] -> Class['pentaho::ctools']
Class['pentaho::biserver'] -> Class['pentaho::biserver::system_databases']
Class['pentaho::config'] -> Class['pentaho::biserver::system_databases']
Class['pentaho::config'] -> Class['pentaho::database']
Class['pentaho::config'] -> Class['pentaho::biserver::config_files']
Class['pentaho::biserver::config_files'] -> Class['pentaho::biserver::run']
Class['pentaho::java'] -> Class['pentaho::biserver']

class pentaho::java {
  Package { ensure => latest }
  package {
    'openjdk-6-jdk':;
    'default-jdk':;
    'libmysql-java':
      notify => Class['pentaho::biserver::run'],
      ensure => absent;
    'libtcnative-1':;
    # pin at 0.9.1.2-5 until #10315 is fixed, see biserver.pp
    'libc3p0-java':
      notify => Class['pentaho::biserver::run'],
      ensure => '0.9.1.2-5';
  }
}

class pentaho::apt_source {
  if !defined(Apt::Source['swellpath']) {
    apt::source { "swellpath":
      location    => "http://swdeb.s3.amazonaws.com",
      release     => "swellpath",
      repos       => "main",
      key         => "4EF797A0",
      key_server  => "subkeys.pgp.net",
      include_src => false,
    }
  }

  exec { "pentaho apt-update":
    command     => "/usr/bin/apt-get update",
    subscribe   => Apt::Source['swellpath'],
    refreshonly => true;
  }

}
