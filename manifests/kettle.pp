class pentaho::kettle {
  include pentaho::java
  include pentaho::apt_source
  include concat::setup

  package { "pentaho-kettle":
    ensure  => "latest",
  }

  $jndisources = '/opt/pentaho/data-integration/simple-jndi/jdbc.properties'
  concat { $jndisources:
    require => Package['pentaho-kettle']
  }
  concat::fragment { "pentaho-kettle-jndi_datasources_header":
    target  => $jndisources,
    content => "# This file is managed by puppet\n",
    order   => '01',
  }

}

class pentaho::kettle::spoon {
  package { 'libswt-mozilla-gtk-3.5-jni':
    ensure => installed;
  }
}
