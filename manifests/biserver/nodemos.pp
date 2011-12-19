class pentaho::biserver::nodemos {
  file { '/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/lib/pentaho-reporting-engine-classic-extensions-sampledata-3.8.3-GA.jar':
    ensure => absent
  }
}

