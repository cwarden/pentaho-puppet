class pentaho::biserver::config_files {
  $tomcat_port = $pentaho::config::tomcat_port
  $jdbc_driver = $pentaho::config::jdbc_driver
  $hibernate_user = $pentaho::config::hibernate_user
  $hibernate_password = $pentaho::config::hibernate_password
  $quartz_user = $pentaho::config::quartz_user
  $quartz_password = $pentaho::config::quartz_password
  $base_url = $pentaho::config::base_url
  $trusted_ip = $pentaho::config::trusted_ip
  $hsql_dialect = $pentaho::config::hsql_dialect
  $publish_password = $pentaho::config::publish_password
  $hibernate_database_type = $pentaho::config::hibernate_database_type

  $hibernate_jdbc_url = "jdbc:${pentaho::config::database_type}://${pentaho::config::database_host}:${pentaho::config::database_port}/${pentaho::config::hibernate_database}"
  $quartz_jdbc_url = "jdbc:${pentaho::config::database_type}://${pentaho::config::database_host}:${pentaho::config::database_port}/${pentaho::config::quartz_database}"

  File { require => Package['pentaho-bi-server'] }
  file {
    "/opt/pentaho/biserver-ce/tomcat/conf/server.xml":
      content => template("pentaho/tomcat/conf/server.xml");
    "/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml":
      content => template("pentaho/tomcat/webapps/pentaho/META-INF/context.xml");
    "/opt/pentaho/biserver-ce/tomcat/conf/Catalina/localhost/pentaho.xml":
      source => "/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml";
    "/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/web.xml":
      content => template("pentaho/tomcat/webapps/pentaho/WEB-INF/web.xml");
    "/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/mantle/loginsettings.properties":
      content => template("pentaho/tomcat/webapps/pentaho/mantle/loginsettings.properties");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-jdbc.xml":
      content => template("pentaho/pentaho-solutions/system/applicationContext-spring-security-jdbc.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties":
      content => template("pentaho/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/pentaho.xml":
      content => template("pentaho/pentaho-solutions/system/pentaho.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/publisher_config.xml":
      content => template("pentaho/pentaho-solutions/system/publisher_config.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/hibernate/hibernate-settings.xml":
      content => template("pentaho/pentaho-solutions/system/hibernate/hibernate-settings.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/hibernate/${pentaho::config::hibernate_database_type}.hibernate.cfg.xml":
      content => template("pentaho/pentaho-solutions/system/hibernate/${pentaho::config::hibernate_database_type}.hibernate.cfg.xml");
  }
}

