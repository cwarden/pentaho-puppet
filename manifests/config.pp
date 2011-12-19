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

