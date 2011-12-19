class pentaho::demos::datasource($username = 'sampledata', $password = 'password') {
  pentaho::datasource { 'SampleData':
    username => $username,
    password => $password,
    type     => 'mysql',
    tables_schema => 'puppet:///modules/pentaho/sampledata.sql',
  }
}

class pentaho::demos::solution {
  pentaho::solution { 'steel-wheels':
    name        => 'Steel Wheels',
    description => 'Reporting, Analysis, and Dashboarding Samples for Steel Wheels, Inc.'
  }
}

class pentaho::demos::catalogs {
  pentaho::catalog {
    'SteelWheels':
      solution        => 'steel-wheels',
      datasource      => 'SampleData',
      mondrian_schema => 'puppet:///modules/pentaho/steelwheels.mondrian.xml';
    'SampleData':
      solution        => 'steel-wheels',
      datasource      => 'SampleData',
      mondrian_schema => 'puppet:///modules/pentaho/SampleData.mondrian.xml';
  }
}
