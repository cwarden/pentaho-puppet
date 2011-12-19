# creates a new solution in the pentaho-solutions directory
define pentaho::solution($description) {
  Class['pentaho::biserver'] -> Pentaho::Solution[$title]
  file {
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}":
      ensure => 'directory';
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}/mondrian":
      ensure => 'directory';
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}/index.properties":
      ensure => 'file',
      content => template('pentaho/pentaho-solutions/solution-template/index.properties');
    "/opt/pentaho/biserver-ce/pentaho-solutions/${title}/index.xml":
      ensure => 'file',
      content => template('pentaho/pentaho-solutions/solution-template/index.xml');
  }
}


