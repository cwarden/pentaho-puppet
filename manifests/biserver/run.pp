class pentaho::biserver::run {
  service { 'bi-server':
    start     => '/bin/su -s /bin/bash -c /opt/pentaho/biserver-ce/start-pentaho.sh pentaho &',
    stop      => '/bin/su -s /bin/bash -c /opt/pentaho/biserver-ce/stop-pentaho.sh pentaho',
    status    => '/bin/netstat -ltpn | awk \'{ print $4}\' |grep -q ":8080"',
    ensure    => running,
    #user     => 'pentaho',
    #group    => 'pentaho',
    require   => File['/opt/pentaho/biserver-ce/start-pentaho-debug.sh'],
    subscribe => [Exec['import hibernate', 'import quartz'], File['/opt/pentaho/biserver-ce/tomcat/conf/Catalina/localhost/pentaho.xml', '/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/web.xml']],
  }
}


