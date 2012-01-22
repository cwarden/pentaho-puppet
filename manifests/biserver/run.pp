class pentaho::biserver::run {
  file {
    '/etc/init.d/bi-server':
      source => 'puppet:///modules/pentaho/bi-server.init',
      owner  => root,
      group  => root,
      mode   => 755;
    '/etc/default/bi-server':
      source => 'puppet:///modules/pentaho/bi-server.default',
      owner  => root,
      group  => root,
      mode   => 755;
    '/opt/pentaho/biserver-ce/tomcat/bin/catalina.sh':
      source => 'puppet:///modules/pentaho/catalina.sh',
      owner  => root,
      group  => root,
      mode   => 755;
  }

  service { 'bi-server':
    ensure    => running,
    enable    => true,
    require   => File['/opt/pentaho/biserver-ce/tomcat/bin/catalina.sh', '/etc/init.d/bi-server'],
    subscribe => [
      Exec[
        'import hibernate',
        'import quartz'
      ],
      File[
        '/etc/init.d/bi-server',
        '/etc/default/bi-server',
        '/opt/pentaho/biserver-ce/tomcat/conf/Catalina/localhost/pentaho.xml',
        '/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/web.xml',
        '/opt/pentaho/biserver-ce/pentaho-solutions/system/pentaho.xml',
        '/opt/pentaho/biserver-ce/pentaho-solutions/system/hibernate/mysql5.hibernate.cfg.xml'
      ]
    ],
  }

}


