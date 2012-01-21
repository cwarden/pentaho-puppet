class pentaho::biserver::refresh {
  Class['pentaho::config'] -> Class['pentaho::biserver::refresh']
  $admin = $pentaho::biserver::admin_user
  $password = $pentaho::biserver::admin_password
  $pentaho_host = 'localhost'
  $pentaho_port = $pentaho::config::tomcat_port
  Exec {
    path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  }

  exec {
    'refresh repository':
      command     => "curl -s http://${pentaho_host}:${pentaho_port}/pentaho/Publish?userid=${admin}&password=${password}&publish=now&class=org.pentaho.platform.engine.services.solution.SolutionPublisher",
      logoutput   => true,
      refreshonly => true;
    'refresh dashboards': # Need to do this separately for now (see http://redmine.webdetails.org/issues/96)
      command     => "curl -s http://${pentaho_host}:${pentaho_port}/pentaho/Publish?publish=now&class=org.pentaho.platform.plugin.services.pluginmgr.PluginAdapter",
      logoutput   => true,
      refreshonly => true;
  }

}
