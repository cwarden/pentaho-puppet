Class['pentaho::biserver'] -> Class['pentaho::config']
Class['pentaho::biserver'] -> Class['pentaho::saiku']
Class['pentaho::biserver'] -> Class['pentaho::ctools']
Class['pentaho::biserver'] -> Class['pentaho::biserver::system_databases']
Class['pentaho::config'] -> Class['pentaho::biserver::system_databases']
Class['pentaho::config'] -> Class['pentaho::database']
Class['pentaho::config'] -> Class['pentaho::biserver::config_files']
Class['pentaho::biserver::config_files'] -> Class['pentaho::biserver::run']
Class['pentaho::java'] -> Class['pentaho::biserver']

class pentaho::java {
  Package { ensure => latest }
  package {
    'openjdk-6-jre':;
    'libmysql-java':;
    'libtcnative-1':;
  }
}
