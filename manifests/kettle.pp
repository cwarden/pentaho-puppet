class pentaho::kettle {
  include pentaho::java
  include pentaho::apt_source

  package { "pentaho-kettle":
    ensure  => "latest",
  }

}
