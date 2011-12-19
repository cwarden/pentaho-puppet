define pentaho::catalog($datasource, $mondrian_schema, $solution) {
  # data sources and the solution directory need to be set up before catalogs
  Pentaho::Datasource[$datasource] -> Pentaho::Catalog[$title]
  Pentaho::Solution[$solution]     -> Pentaho::Catalog[$title]
  Pentaho::Catalog[$title]         -> Class['pentaho::biserver::run']

  $basename = basename($mondrian_schema)

  file {
    "/opt/pentaho/biserver-ce/pentaho-solutions/${solution}/mondrian/${basename}":
      source => $mondrian_schema
  }

  include pentaho::mondrian
  concat::fragment { "datasources_catalog_${title}":
    target  => $pentaho::mondrian::datasources,
    content => template('pentaho/pentaho-solutions/system/olap/datasources-catalog.xml')
  }
}

