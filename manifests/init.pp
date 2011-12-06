Class['pentaho::biserver'] -> Class['pentaho::config']
Class['pentaho::biserver'] -> Class['pentaho::saiku']
Class['pentaho::config'] -> Class['pentaho::database']

class pentaho::biserver($demos = true) {
  class { 'mysql': }

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

  file { "/opt/pentaho/biserver-ce/data/puppet":
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '700',
  }
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
  notify { 'tags':
    message => inline_template('
<% tags.each do |tag| -%>
The tag <%= tag %> is part of the current scope
<% end -%>')
  }

  $hibernate_database_type = $database_type ? {
    /mysql5?/ => 'mysql5',
    /postgres(ql)?/ => 'postgresql',
    /oracle(10g)?/  => 'oracle10g',
    /hsql/          => 'hsql'
  }

  if tagged('pentaho::biserver') {
    $hibernate_jdbc_url = "jdbc:${hibernate_database_type}://${database_host}:${database_port}/${hibernate_database}"
    $quartz_jdbc_url = "jdbc:${hibernate_database_type}://${database_host}:${database_port}/${quartz_database}"

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
    $create_hibernate_sql = "/opt/pentaho/biserver-ce/data/puppet/create_hibernate_datasource_table.sql"
    file { $create_hibernate_sql:
      #ensure => present,
      source => 'puppet:///modules/pentaho/create_hibernate_datasource_table.sql',
    }

    $create_quartz_sql = "/opt/pentaho/biserver-ce/data/puppet/create_quartz_mysql.sql"
    file { $create_quartz_sql:
      #ensure => present,
      source => 'puppet:///modules/pentaho/create_quartz_mysql.sql',
    }

    Exec {
      path => [ '/usr/local/bin', '/usr/bin', '/bin' ]
    }

    case $database_type {
      'mysql':  {
        $mysql_hibernate = "mysql -h${database_host} -u${hibernate_user} -p${hibernate_password} ${hibernate_database}"
        $mysql_quartz = "mysql -h${database_host} -u${quartz_user} -p${quartz_password} ${quartz_database}"
        exec {
          "import hibernate":
            command     => "${mysql_hibernate} < ${create_hibernate_sql}",
            #unless      => "echo 'SHOW TABLES' | ${mysql_hibernate} | grep -q DATASOURCE",
            #refreshonly => true,
            require     => File[$create_hibernate_sql];
          "import quartz":
            command     => "${mysql_quartz} < ${create_quartz_sql}",
            unless      => "echo 'SHOW TABLES' | ${mysql_quartz} | grep -q QRTZ_JOB_LISTENERS",
            refreshonly => true,
            require     => File[$create_hibernate_sql];
        }
      }
    }
  } else {
    warning('not tagged pentaho::biserver')
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

  if tagged('pentaho::biserver') {
    $url = "jdbc:${type}://${pentaho::config::database_host}:${pentaho::config::database_port}/${title}"
    $schema_file = md5($table_schema)
    $schema_path = "/opt/pentaho/biserver-ce/data/puppet/${schema_file}"
    file { "${schema_path}":
      owner   => 'puppet',
      mode    => '600',
      content => $schema
    }
    exec { "create $title schema":
      command => "mysql -h ${pentaho::config::database_host} -u${pentaho::config::hibernate_user} -p${pentaho::config::hibernate_password} ${pentaho::config::hibernate_database} < ${schema_path}",
      refreshonly => true,
      require => File[$schema_path],
    }
    
    # creates a file containing sql to populate datasource record, then execs mysql client
    $sql = "REPLACE INTO `DATASOURCE` (`NAME`, `DRIVERCLASS`, `USERNAME`, `PASSWORD`, `URL`)
      VALUES ('${title}', '${driver}', '${username}', '${password}', '${url}')"
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
      require => File[$sql_path]
    }
  } elsif tagged('pentaho::database') {
    mysql::db { $title:
      user     => $username,
      password => $password,
      # TODO: restrict hosts
      host     => '%',
      grant    => ['all'],
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
      source => $schema
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
