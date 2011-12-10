Class['pentaho::biserver'] -> Class['pentaho::config']
Class['pentaho::biserver'] -> Class['pentaho::saiku']
Class['pentaho::biserver'] -> Class['pentaho::biserver::system_databases']
Class['pentaho::config'] -> Class['pentaho::biserver::system_databases']
Class['pentaho::config'] -> Class['pentaho::database']
Class['pentaho::config'] -> Class['pentaho::biserver::config_files']
Class['pentaho::biserver::config_files'] -> Class['pentaho::biserver::run']

class pentaho::biserver::run {
  service { 'start-bi-server':
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

class pentaho::biserver::nodemos {
  file { '/opt/pentaho/biserver-ce/tomcat/webapps/pentaho/WEB-INF/lib/pentaho-reporting-engine-classic-extensions-sampledata-3.8.3-GA.jar':
    ensure => absent
  }
}

class pentaho::demos::datasource {
  pentaho::datasource { 'SampleData':
    username => 'sampledata',
    password => 'La4saiZi',
    type     => 'mysql',
    tables_schema => 'puppet:///modules/pentaho/sampledata.sql',
  }
}

class pentaho::demos::solution {
  pentaho::solution { 'steel-wheels':
    name        => 'Steel Wheels',
    description => 'Reporting, Analysis, and Dashboarding Samples for Steel Wheels, Inc.'
  }
}
class pentaho::demos::catalogs {
  pentaho::catalog {
    'SteelWheels':
      solution        => 'steel-wheels',
      datasource      => 'SampleData',
      mondrian_schema => 'puppet:///modules/pentaho/steelwheels.mondrian.xml';
    'SampleData':
      solution        => 'steel-wheels',
      datasource      => 'SampleData',
      mondrian_schema => 'puppet:///modules/pentaho/SampleData.mondrian.xml';
  }
}


class pentaho::biserver {
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
  class { 'mysql': }

  file { "pentaho-bi-server_3.10.0_all.deb":
    path   => "/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb",
    source => "puppet:///modules/pentaho/pentaho-bi-server_3.10.0_all.deb",
  }

  Package { ensure => latest }
  package {
    'openjdk-6-jre':;
    'libmysql-java':;
    'libtcnative-1':;
  }

  package { "pentaho-bi-server":
    ensure  => "present",
    provider => "dpkg",
    source  => '/var/cache/apt/archives/pentaho-bi-server_3.10.0_all.deb',
    require => [File['pentaho-bi-server_3.10.0_all.deb'], Package['openjdk-6-jre', 'libmysql-java']],
  }

  file { "/opt/pentaho/biserver-ce/data/puppet":
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
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
      '/opt/pentaho/.kettle': ensure => directory;
      '/opt/pentaho/.tonbeller': ensure => directory;
      '/opt/pentaho/.pentaho': ensure => directory;
      '/opt/pentaho/.kettle/kettle.properties': ensure => file;
    }
  }

  include tomcat-writable

}

# installs the database server and creates the hibernate and quartz databases
class pentaho::database($type = 'mysql', $admin_password) {
  case $type {
    'mysql': {
      class { 'mysql::server':
        config_hash => {
          'root_password' => $admin_password,
          'bind_address'  => tagged('pentaho::biserver') ?  {
            true  => '127.0.0.1',
            false => '0.0.0.0'
          }
        }
      }

      mysql::db { $pentaho::config::hibernate_database:
        user     => $pentaho::config::hibernate_user,
        password => $pentaho::config::hibernate_password,
        # TODO: restrict hosts
        host     => '%',
        grant    => ['all'],
      }

      mysql::db { $pentaho::config::quartz_database:
        user     => $pentaho::config::quartz_user,
        password => $pentaho::config::quartz_password,
        # TODO: restrict hosts
        host     => '%',
        grant    => ['all'],
      }

    }
    default: { fail("Unrecognized database type") }
  }
}

class pentaho::config(
  $base_url = 'http://127.0.0.1:8080/pentaho/',
  $trusted_ip = '127.0.0.1',
  $jdbc_driver = 'com.mysql.jdbc.Driver',
  $tomcat_port = '8080',
  $database_type = 'mysql',
  $database_host = 'localhost',
  $database_port = '3306',
  $hibernate_database = 'hibernate',
  $hibernate_user = 'hibuser',
  $hibernate_password,
  $quartz_database = 'quartz',
  $quartz_user = 'pentaho_user',
  $quartz_password,
  $publish_password,
  $hsql_dialect = 'org.hibernate.dialect.MySQLDialect'
) {

  $hibernate_database_type = $database_type ? {
    /mysql5?/ => 'mysql5',
    /postgres(ql)?/ => 'postgresql',
    /oracle(10g)?/  => 'oracle10g',
    /hsql/          => 'hsql'
  }


}

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

class pentaho::biserver::system_databases {
  $create_hibernate_sql = "/opt/pentaho/biserver-ce/data/puppet/create_hibernate_tables.sql"
  file { $create_hibernate_sql:
    #ensure => present,
    source => 'puppet:///modules/pentaho/create_hibernate_tables.sql',
  }

  $create_quartz_sql = "/opt/pentaho/biserver-ce/data/puppet/create_quartz_mysql.sql"
  file { $create_quartz_sql:
    #ensure => present,
    source => 'puppet:///modules/pentaho/create_quartz_mysql.sql',
  }

  Exec {
    path    => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    require => tagged('mysqlserver') ? { true => Class['pentaho::database'], default => undef }
  }

  case $pentaho::config::database_type {
    'mysql':  {
      $mysql_hibernate = "mysql -h${pentaho::config::database_host} -u${pentaho::config::hibernate_user} -p${pentaho::config::hibernate_password} ${pentaho::config::hibernate_database}"
      $mysql_quartz = "mysql -h${pentaho::config::database_host} -u${pentaho::config::quartz_user} -p${pentaho::config::quartz_password} ${pentaho::config::quartz_database}"
      exec {
        "import hibernate":
          command     => "${mysql_hibernate} < ${create_hibernate_sql}",
          #unless     => "echo 'SHOW TABLES' | ${mysql_hibernate} | grep -q DATASOURCE",
          refreshonly => true,
          subscribe   => File[$create_hibernate_sql];
        "import quartz":
          command     => "${mysql_quartz} < ${create_quartz_sql}",
          unless      => "echo 'SHOW TABLES' | ${mysql_quartz} | grep -q QRTZ_JOB_LISTENERS",
          refreshonly => true,
          subscribe   => File[$create_quartz_sql];
      }
    }
  }
}

class pentaho::mondrian {
  include concat::setup
  $datasources = '/opt/pentaho/biserver-ce/pentaho-solutions/system/olap/datasources.xml'
  concat { $datasources: }
  concat::fragment { "datasources_header":
    target  => $datasources,
    content => template('pentaho/pentaho-solutions/system/olap/datasources-header.xml'),
    order   => '01',
  }
  concat::fragment { "datasources_footer":
    target  => $datasources,
    content => template('pentaho/pentaho-solutions/system/olap/datasources-footer.xml'),
    order   => '99',
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

# creates database on mysql server. creates config files and database tables on biserver.
define pentaho::datasource($type = 'mysql', $driver = 'com.mysql.jdbc.Driver', $username, $password, $tables_schema) {
  Class['pentaho::config'] -> Pentaho::Datasource[$title]

  Exec {
    path => [ '/usr/local/bin', '/usr/bin', '/bin' ]
  }

  # FIXME: this should only depend on tags within the module
  if tagged('biserver') {
    notify { "building datasource ${title}": }
    $schema_file = md5($tables_schema)
    $schema_path = "/opt/pentaho/biserver-ce/data/puppet/${schema_file}"
    file { $schema_path:
      owner   => 'puppet',
      mode    => '600',
      ensure  => file,
      source  => $tables_schema
    }
    exec { "create $title schema":
      command => "mysql -h ${pentaho::config::database_host} -u${username} -p${password} ${title} < ${schema_path}",
      refreshonly => true,
      subscribe => [File[$schema_path], Exec['import hibernate']],
    }

    $url = "jdbc:${type}://${pentaho::config::database_host}:${pentaho::config::database_port}/${title}"
    # creates a file containing sql to populate datasource record, then execs mysql client
    $sql_tmpl = "<% require 'base64' %>REPLACE INTO `DATASOURCE` (`NAME`, `DRIVERCLASS`, `USERNAME`, `PASSWORD`, `URL`)
      VALUES ('${title}', '${driver}', '${username}', '<%= Base64.encode64(\"${password}\") -%>', '${url}');"
    $sql = inline_template($sql_tmpl)
    $sql_file = md5($sql)
    $sql_path = "/opt/pentaho/biserver-ce/data/puppet/${sql_file}"

    file { "${sql_path}":
      owner   => 'puppet',
      mode    => '600',
      content => $sql,
    }
    exec { "create datasource $title":
      command => "mysql -h ${pentaho::config::database_host} -u${pentaho::config::hibernate_user} -p${pentaho::config::hibernate_password} ${pentaho::config::hibernate_database} < ${sql_path}",
      refreshonly => true,
      subscribe => File[$sql_path]
    }
  } 
  if tagged('mysqlserver') {
    Class['pentaho::database'] -> Pentaho::Datasource[$title]
    mysql::db { $title:
      user     => $username,
      password => $password,
      # TODO: restrict hosts
      host     => '%',
      grant    => ['all'],
      before   => tagged('biserver') ? { true => Exec["create $title schema"], default => undef }
    }
  }
}

define pentaho::catalog($datasource, $mondrian_schema, $solution) {
  # data sources and the solution directory need to be set up before catalogs
  Pentaho::Datasource[$datasource] -> Pentaho::Catalog[$title]
  Pentaho::Solution[$solution]     -> Pentaho::Catalog[$title]

  $path = split($mondrian_schema, '/')
  $basename = $path[-1]

  file {
    "/opt/pentaho/biserver-ce/pentaho-solutions/${solution}/mondrian/${basename}":
      source => $mondrian_schema
  }

  include pentaho::mondrian
  concat::fragment { "datasources_catalog_${title}":
    target  => $pentaho::mondrian::datasources,
    content => template('pentaho/pentaho-solutions/system/olap/datasources-catalog.xml')
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
