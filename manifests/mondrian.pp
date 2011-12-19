# creates datasources.xml
class pentaho::mondrian {
  include concat::setup
  $datasources = '/opt/pentaho/biserver-ce/pentaho-solutions/system/olap/datasources.xml'
  concat { $datasources: }
  concat::fragment { "datasources_header":
    target  => $datasources,
    content => template('pentaho/pentaho-solutions/system/olap/datasources-header.xml'),
    order   => '01',
  }
  concat::fragment { "datasources_footer":
    target  => $datasources,
    content => template('pentaho/pentaho-solutions/system/olap/datasources-footer.xml'),
    order   => '99',
  }
}


