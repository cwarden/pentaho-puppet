class pentaho::biserver::refresh {
  Class['pentaho::config'] -> Class['pentaho::biserver::refresh']
  $admin = $pentaho::biserver::admin_user
  $password = $pentaho::biserver::admin_password
  $pentaho_host = 'localhost'
  $pentaho_port = $pentaho::config::tomcat_port
  Exec {
    path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
  }

  exec {
    'refresh repository':
      command     => "curl -s 'http://${pentaho_host}:${pentaho_port}/pentaho/Publish?userid=${admin}&password=${password}&publish=now&class=org.pentaho.platform.engine.services.solution.SolutionPublisher' | grep 'The Solution Repository has been updated'",
      logoutput   => true,
      require     => Service['bi-server'],
      refreshonly => true;
    'refresh dashboards': # Need to do this separately for now (see http://redmine.webdetails.org/issues/96)
      command     => "curl -s 'http://${pentaho_host}:${pentaho_port}/pentaho/Publish?publish=now&style=popup&class=org.pentaho.platform.plugin.services.pluginmgr.PluginAdapter&userid=${admin}&password=${password}' | grep 'Plugin Community Dashboard Editor has registered successfully'",
      # FIXME: 15 new connections to MySQL are opened every time this runs.  So restart the BI server for now.
      notify      => Exec['biserver restart hack'],
      require     => Service['bi-server'],
      logoutput   => true,
      refreshonly => true;
  }

  # Need to restart BI server using a separate exec rather than the service to avoid dependency cycle
  exec { 'biserver restart hack':
    command     => 'service bi-server restart',
    refreshonly => true,
  }

}
