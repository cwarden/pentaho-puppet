class pentaho::cst {
  require pentaho::apt_source
  require concat::setup
  package { "pentaho-cst":
    ensure   => "latest",
    notify   => Service['bi-server'],
  }

  pentaho::biserver::acl-entry{ 'CST - Authenticated':
    role          => 'Authenticated',
    solution      => 'CST',
    execute_perm  => true,
    position      => 1
  }

  pentaho::biserver::acl-entry{ 'CST - Admin':
    role          => 'Admin',
    solution      => 'CST',
    full_control  => true,
    position      => 0
  }

  $cst_config = '/opt/pentaho/biserver-ce/pentaho-solutions/CST/cst-config.xml'
  concat { $cst_config:
  }
  concat::fragment {
    'cst-config-header':
      target  => $cst_config,
      order   => '01',
      content => '<?xml version="1.0"?><cstConfig>';
    'cst-config-footer':
      target  => $cst_config,
      order   => '99',
      content => '</cstConfig>';
  }

}

