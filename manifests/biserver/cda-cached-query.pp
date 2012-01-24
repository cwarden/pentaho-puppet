define pentaho::biserver::cda-cached-query($solution, $cdaFile = 'Dashboard1.cda', $query, $cron_string = "0 3 * * * ?", $params = []) {
  Class['pentaho::config'] -> Pentaho::Biserver::Cda-cached-query[$title]
  $admin = $pentaho::biserver::admin_user
  $password = $pentaho::biserver::admin_password
  $pentaho_host = 'localhost'
  $pentaho_port = $pentaho::config::tomcat_port

  $curl_tmpl = "<%
    require 'json'
    require 'uri'
    object = {
      'cdaFile'      => solution + '/' + cdaFile,
      'dataAccessId' => query,
      'cronString'   => cron_string,
      'parameters'   => []
    }
    params.each do |param|
      param.keys.each do |key|
        object['parameters'].push({'name' => key, 'value' => param[key]})
      end
    end
    json = JSON.generate object
    url_encoded = URI.encode(json)
    vhost = '${pentaho_host}:${pentaho_port}'
    url = 'http://' + vhost + '/pentaho/content/cda/cacheController?method=change&object=' + url_encoded + '&userid=' + admin + '&password=' + password
    %>
#!/bin/bash

/usr/bin/curl --globoff --silent '<%= url %>'"

  $curl = inline_template($curl_tmpl)
  $hash = md5($curl)
  $script_path = "/opt/pentaho/biserver-ce/data/puppet/create-schedule-${hash}.sh"

  file { "${script_path}":
    owner   => 'root',
    mode    => '700',
    content => $curl,
    notify  => Class['pentaho::biserver::refresh']
  }

  exec { "cache cda query: $title":
    command     => "$script_path | grep '\"status\": \"ok\"'",
    user        => 'root',
    group       => 'root',
    logoutput   => true,
    refreshonly => true,
    require     => Class['pentaho::biserver::refresh'],
    subscribe   => File[$script_path],
  }
}
