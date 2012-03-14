## pentaho module

### Overview

This module can install and configure the open source Pentaho BI suite on a
Debian-based system.

### Example

````
# This should create a usable server with the default accounts/data
node pentahodemo {
  # this is both a MySQL server and a BI (tomcat) server
  tag('mysqlserver')
  tag('biserver')
  # set up configuration shared between classes
  class {
    'pentaho::config':
      hibernate_user     => 'hibuser',
      hibernate_password => 'password',
      quartz_user        => 'pentaho_user',
      quartz_password    => 'password',
      publish_password   => 'publish',
      database_host      => 'localhost'
  }
  # install MySQL and set a password for the root user
  class { 'pentaho::database':
      admin_password => 'rootytooty';
  }
  # Install the BI Server and a recent version of ctools (including saiku)
  class {
    'pentaho::biserver':
      admin_user     => 'admin',
      admin_password => 'password';
    'pentaho::ctools':;
  }
  # Setup config file, hibernate and quartz databases, and default user groups (authorities)
  class {
    'pentaho::biserver::config_files':;
    'pentaho::biserver::system_databases':;
    'pentaho::biserver::default_authorities':;
  }
  # Set up the sample data
  class {
    'pentaho::demos::datasource':
      username => 'sampledata',
      password => 'sampledata';
    'pentaho::demos::solution':;
    'pentaho::demos::catalogs':;
  }
  # Start up the BI server
  class {
    'pentaho::biserver::run':;
  }
  # create an admin user to log in
  pentaho::biserver::user{ 'admin user':
    username => 'joe',
    password => 'password',
    authorities => ['Authenticated', 'Admin']
  }
}
````
