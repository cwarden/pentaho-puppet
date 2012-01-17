# creates a biserver authority (group)
define pentaho::biserver::authority($authority = $title, $description = '') {
  Class['pentaho::biserver::system_databases'] -> Pentaho::Biserver::Authority[$title]
  Pentaho::Biserver::Authority[$title] -> Class['pentaho::biserver::run']

  Exec {
    path => [ '/usr/local/bin', '/usr/bin', '/bin' ]
  }

  $sql_tmpl = "INSERT INTO AUTHORITIES (AUTHORITY, DESCRIPTION) VALUES ('${authority}', '${description}')
      ON DUPLICATE KEY UPDATE DESCRIPTION = '${description}';"
  $sql = inline_template($sql_tmpl)
  $sql_file = md5($sql)
  $sql_path = "/opt/pentaho/biserver-ce/data/puppet/create-authority-${sql_file}.sql"

  file { "${sql_path}":
    owner   => 'root',
    mode    => '600',
    content => $sql,
  }
  exec { "create biserver authority $title":
    command => "mysql -h ${pentaho::config::database_host} -u${pentaho::config::hibernate_user} -p${pentaho::config::hibernate_password} ${pentaho::config::hibernate_database} < ${sql_path} || rm -f $sql_path",
    refreshonly => true,
    subscribe => File[$sql_path]
  }

}
