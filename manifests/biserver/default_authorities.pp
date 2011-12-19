class pentaho::biserver::default_authorities {
  Class['pentaho::biserver::system_databases'] -> Class['pentaho::biserver::default_authorities']
  $create_default_authorities_sql = "/opt/pentaho/biserver-ce/data/puppet/default_authorities.sql"
  file { $create_default_authorities_sql:
    #ensure => present,
    source => 'puppet:///modules/pentaho/default_authorities.sql',
  }

  Exec {
    path    => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    require => tagged('mysqlserver') ? { true => Class['pentaho::database'], default => undef }
  }

  case $pentaho::config::database_type {
    'mysql':  {
      $mysql = "mysql -h${pentaho::config::database_host} -u${pentaho::config::hibernate_user} -p${pentaho::config::hibernate_password} ${pentaho::config::hibernate_database}"
      exec {
        "import default authorities":
          command     => "${mysql} < ${create_default_authorities_sql}",
          refreshonly => true,
          subscribe   => File[$create_default_authorities_sql],
          require     => Exec['import hibernate'] # this shouldn't be required with the class dependency above..
      }
    }
  }
}

