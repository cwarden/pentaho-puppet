Class['pentaho::biserver'] -> Class['pentaho::config']
Class['pentaho::biserver'] -> Class['pentaho::saiku']

class pentaho::biserver($demos = true) {
# TODO: remove demo stuff if $demos is false
  file { "pentaho-bi-server_3.10.0_all.deb":
    path   => "/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb",
    source => "puppet:///modules/pentaho/pentaho-bi-server_3.10.0_all.deb",
  }

  package { "openjdk-6-jre":
    ensure => latest,
  }

  package { "pentaho-bi-server":
    ensure  => "present",
    provider => "dpkg",
    source  => "/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb",
    require => [File["pentaho-bi-server_3.10.0_all.deb"], Package["openjdk-6-jre"]],
  }
}

class pentaho::config(
  $base_url = 'http://127.0.0.1:8080/pentaho/',
  $trusted_ip = '127.0.0.1',
  $jdbc_driver = 'com.mysql.jdbc.Driver',
  $tomcat_port = '8080',
  $hibernate_database_type = 'mysql5',
  $hibernate_jdbc_url = 'jdbc:mysql://localhost:3306/hibernate',
  $hibernate_user = 'hibuser',
  $hibernate_password,
  $quartz_jdbc_url = 'jdbc:mysql://localhost:3306/quartz',
  $quartz_user = 'pentaho_user',
  $quartz_password,
  $publish_password,
  $hsql_dialect = 'org.hibernate.dialect.MySQLDialect'
) {
  file {
    "/opt/pentaho/biserver-ce/tomcat/conf/server.xml":
      content => template("pentaho/tomcat/conf/server.xml");
    "/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml":
      content => template("pentaho/tomcat/webapps/pentaho/META-INF/context.xml");
    "/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/web.xml":
      content => template("pentaho/tomcat/webapps/pentaho/WEB-INF/web.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-jdbc.xml":
      content => template("pentaho/pentaho-solutions/system/applicationContext-spring-security-jdbc.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties":
      content => template("pentaho/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/publisher_config.xml":
      content => template("pentaho/pentaho-solutions/system/publisher_config.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/hibernate/hibernate-settings.xml":
      content => template("pentaho/pentaho-solutions/system/hibernate/hibernate-settings.xml");
    "/opt/pentaho/biserver-ce/pentaho-solutions/system/hibernate/${hibernate_database_type}.hibernate.cfg.xml":
      content => template("pentaho/pentaho-solutions/system/hibernate/${hibernate_database_type}.hibernate.cfg.xml");
  }

  $catalogs = [ { name => 'test catalog', datasource => 'my datasource', schema => 'some-schema.xml', solution => 'a solution' } ]

}

class pentaho::mondrian {
  file { 'datasources.xml':
    path    => "/opt/pentaho/biserver-ce/pentaho-solutions/system/olap/datasources.xml",
    content => template('pentaho/pentaho-solutions/system/olap/datasources.xml')
  }
}

class pentaho::saiku {
  file { "saiku-plugin_2.2-SNAPSHOT-20111201_all.deb":
   path   => "/var/cache/apt/archives/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
   source => "puppet:///modules/pentaho/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
  }

  package { "saiku-plugin":
    ensure  => "present",
   provider => "dpkg",
    source  => "/var/cache/apt/archives/saiku-plugin_2.2-SNAPSHOT-20111201_all.deb",
   require  => [File["saiku-plugin_2.2-SNAPSHOT-20111201_all.deb"], Class["pentaho::biserver"]],
  }
}

define pentaho::datasource($url, $driver = 'com.mysql.jdbc.Driver', $username, $password) {
  Class['pentaho::config'] -> Pentaho::Datasource[$title]
  # TODO: create the record in the hibernate.DATASOURCE table
  file { "/tmp/${title}-datasource":
    content => "
driver: ${driver}
username: ${username}
tomcat_port: $pentaho::config::tomcat_port
hibernate_user: $pentaho::config::hibernate_user
hibernate_password: $pentaho::config::hibernate_password
"
  }
}

define pentaho::catalog($datasource, $schema, $solution) {
  # data sources and the solution directory need to be set up before catalogs
  Pentaho::Datasource[$datasource] -> Pentaho::Catalog[$title]
  Pentaho::Solution[$solution]     -> Pentaho::Catalog[$title]
  # datasources.xml should be generated after all catalogs are defined
  Pentaho::Catalog[$title]         -> File['datasources.xml']
  include pentaho::mondrian

  $path = split($schema, '/')
  $basename = $path[-1]
  # FIXME: this doesn't work because the array's new value is only in this scope
  $pentaho::config::catalogs += [ { name => $title, datasource => $datasource, schema => $basename, solution => $solution } ]
  file {
    "/opt/pentaho/biserver-ce/pentaho-solutions/${solution}/mondrian/${basename}":
      source => $schema
  }
}

define pentaho::solution($description) {
  Class['pentaho::biserver'] -> Pentaho::Solution[$title]
  file {
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}":
      ensure => 'directory';
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}/mondrian":
      ensure => 'directory';
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}/index.properties":
      ensure => 'file',
      content => template('pentaho/pentaho-solutions/solution-template/index.properties');
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}/index.xml":
      ensure => 'file',
      content => template('pentaho/pentaho-solutions/solution-template/index.xml');
  }
}
