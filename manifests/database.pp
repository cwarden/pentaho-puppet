# installs the database server and creates the hibernate and quartz databases
class pentaho::database($type = 'mysql', $admin_password) {
  case $type {
    'mysql': {
      if !defined(Class['mysql::server']) {
        class { 'mysql::server':
          config_hash => {
            'root_password' => $admin_password,
            'bind_address'  => tagged('pentaho::biserver') ?  {
              true  => '127.0.0.1',
              false => '0.0.0.0'
            }
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

