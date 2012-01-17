# creates a biserver user.  the authorities should already exist.
define pentaho::biserver::user($username = $title, $password, $authorities = ['Authenticated'], $description = '') {
  Class['pentaho::biserver::system_databases'] -> Pentaho::Biserver::User[$title]
  Pentaho::Biserver::User[$title] -> Class['pentaho::biserver::run']

  Exec {
    path => [ '/usr/local/bin', '/usr/bin', '/bin' ]
  }

  $sql_tmpl = "<% require 'base64'; pass = Base64.encode64(\"${password}\").strip %>
    BEGIN;
    DELETE FROM GRANTED_AUTHORITIES WHERE USERNAME = '${username}';
    INSERT INTO USERS (USERNAME, PASSWORD, ENABLED, DESCRIPTION) VALUES ('${username}', '<%= pass -%>', 1, '${description}')
      ON DUPLICATE KEY UPDATE PASSWORD = '<%= pass %>', ENABLED = 1, DESCRIPTION = '${description}';
    <% authorities.each do |val| -%>
    INSERT INTO GRANTED_AUTHORITIES (USERNAME, AUTHORITY) VALUES ('${username}', '<%= val -%>');
    <% end %>
    COMMIT;"
  $sql = inline_template($sql_tmpl)
  $sql_file = md5($sql)
  $sql_path = "/opt/pentaho/biserver-ce/data/puppet/create-user-${sql_file}.sql"

  file { "${sql_path}":
    owner   => 'root',
    mode    => '600',
    content => $sql,
  }
  exec { "create biserver user $title":
    command => "mysql -h ${pentaho::config::database_host} -u${pentaho::config::hibernate_user} -p${pentaho::config::hibernate_password} ${pentaho::config::hibernate_database} < ${sql_path} || rm -f $sql_path",
    refreshonly => true,
    subscribe => File[$sql_path]
  }
}
