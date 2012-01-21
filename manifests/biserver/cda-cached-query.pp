define pentaho::biserver::cda-cached-query($solution, $cdaFile = 'Dashboard1.cda', $query, $cron_string = "0 3 * * * ?", $params = []) {
  Class['pentaho::config'] -> Pentaho::Biserver::Cda-cached-query[$title]
  $admin = $pentaho::biserver::admin_user
  $password = $pentaho::biserver::admin_password
  $pentaho_host = 'localhost'
  $pentaho_port = $pentaho::config::tomcat_port

  $url_tmpl = "<%
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
    %><%= url -%>"

  # TODO: write a file and enable refreshonly
  $url = inline_template($url_tmpl)
  exec { "cache cda query: $title":
    command => "/usr/bin/curl --globoff --silent '${url}'",
    logoutput => true,
  }
}
