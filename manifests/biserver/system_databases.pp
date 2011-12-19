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

