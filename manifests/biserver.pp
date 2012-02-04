class pentaho::biserver($admin_user = 'admin', $admin_password) {
  # At least one admin user must be created by passing $admin_password and
  # optionally, $admin_user. Additional admin users can be created with
  # pentaho::biserver::user.
  include pentaho::java
  require pentaho::apt_source
  include pentaho::biserver::refresh
  include mysql

  pentaho::biserver::user{ 'admin user':
    username => $admin_user,
    password => $admin_password,
    authorities => ['Authenticated', 'Admin']
  }

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

  package { "pentaho-bi-server":
    ensure  => "latest",
  }

  # refresh the repository
  # http://reporting.swellpath.com:8088/pentaho/Publish?publish=now&style=popup&class=org.pentaho.platform.engine.services.solution.SolutionPublisher&userid=<admin>&password=<admin-password>

  file { "/opt/pentaho/biserver-ce/data/puppet":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '700',
    recurse => true,
    purge   => true,
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
      '/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/lib/c3p0.jar':
        ensure => 'file',
        links  => 'follow',
        mode   => '644',
        notify => Service['bi-server'],
        # following symlinks broken so we can't copy the target of a symlink: http://projects.puppetlabs.com/issues/10315
        # source => '/usr/share/java/c3p0.jar';
        source => '/usr/share/java/c3p0-0.9.1.2.jar';
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

