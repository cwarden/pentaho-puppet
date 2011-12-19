class pentaho::biserver {
  include pentaho::java
  include mysql
  group { 'pentaho':
    ensure => present,
    system => true,
  }
  user { 'pentaho':
    ensure => present,
    gid    => 'pentaho',
    home   => '/opt/pentaho',
    system => true
  }

  file { "pentaho-bi-server_3.10.0_all.deb":
    path   => "/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb",
    source => "puppet:///modules/pentaho/pentaho-bi-server_3.10.0_all.deb",
  }

  package { "pentaho-bi-server":
    ensure  => "present",
    provider => "dpkg",
    source  => '/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb',
    require => [File['pentaho-bi-server_3.10.0_all.deb'], Package['openjdk-6-jre']]
  }

  file { "/opt/pentaho/biserver-ce/data/puppet":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '700',
    require => Package['pentaho-bi-server']
  }

  class files {
    File {
      require => [ Group['pentaho'], Package['pentaho-bi-server']],
    }
    file {
      '/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/classes/log4j.xml':
        source => 'puppet:///modules/pentaho/log4j.xml',
        owner => 'root',
        group => 'root',
        ensure => present;
      '/opt/pentaho/biserver-ce/promptuser.sh':
        ensure => absent;
      '/opt/pentaho/biserver-ce/start-pentaho.sh':
        source => 'puppet:///modules/pentaho/start-pentaho.sh',
        mode => '755',
        owner => 'root',
        group => 'root';
      '/opt/pentaho/biserver-ce/start-pentaho-debug.sh':
        source => 'puppet:///modules/pentaho/start-pentaho-debug.sh',
        mode => '755',
        owner => 'root',
        group => 'root';
    }
  }

  include files

  class tomcat-writable {
    File {
      group => 'pentaho',
      mode  => '770',
      require => [ Group['pentaho'], Package['pentaho-bi-server']],
    }
    file {
      '/opt/pentaho/biserver-ce/tomcat/logs': ensure => directory;
      '/opt/pentaho/biserver-ce/tomcat/work': ensure => directory;
      '/opt/pentaho/biserver-ce/tomcat/temp': ensure => directory;
      '/opt/pentaho/biserver-ce/pentaho-solutions/system/tmp': ensure => directory;
      '/opt/pentaho/biserver-ce/pentaho-solutions/system/logs': ensure => directory, recurse => true;
      '/opt/pentaho/biserver-ce/tomcat/conf/Catalina': ensure => directory;
      '/opt/pentaho/biserver-ce/tomcat/conf/Catalina/localhost': ensure => directory;
      '/opt/pentaho/biserver-ce/pentaho-solutions': ensure => directory, recurse => false;
      '/opt/pentaho/biserver-ce/pentaho-solutions/system/pentaho-cdf/tmp': ensure => directory;
      '/opt/pentaho/biserver-ce/pentaho-solutions/system/pentaho-cdf-dd': ensure => directory, recurse => false;
      '/opt/pentaho/biserver-ce/pentaho-solutions/system/pentaho-cdf-dd/js': ensure => directory, recurse => true;
      '/opt/pentaho/biserver-ce/pentaho-solutions/system/pentaho-cdf-dd/css': ensure => directory, recurse => true;
      '/opt/pentaho/biserver-ce/pentaho-solutions/system/pentaho-cdf/js': ensure => directory, recurse => true;
      '/opt/pentaho/.kettle': ensure => directory;
      '/opt/pentaho/.tonbeller': ensure => directory;
      '/opt/pentaho/.pentaho': ensure => directory;
      '/opt/pentaho/.kettle/kettle.properties': ensure => file;
    }
  }

  include tomcat-writable

}

