class pentaho::biserver::proxy($vhost_name = 'pentaho', $aliases = [], $vhost_port = 80, $ssl = false, $ssl_vhost_name = $vhost_name, $vhost_name, $ssl_vhost_port = 443, $ssl_key = undef, $ssl_cert = undef) {
  include nginx

  $alias_string = inline_template('<% aliases.each do |host_alias| -%> <%= host_alias -%><% end -%>')
  $server_names = "${vhost_name} ${alias_string}"
  nginx::resource::upstream { 'bi-server':
    ensure  => present,
    members => [
      'localhost:8080',
    ],
  }
  nginx::resource::vhost { "biserver":
    server_name => $server_names,
    listen_port => $vhost_port,
    ensure   => present,
    proxy  => 'http://bi-server',
    ssl         => $ssl ? {
      true    => 'true',
      default => 'false'
    },
    ssl_cert    => '/etc/nginx/ssl/biserver.crt',
    ssl_key     => '/etc/nginx/ssl/biserver.key',
    require     => $ssl ? {
      true => File['/etc/nginx/ssl/biserver.crt', '/etc/nginx/ssl/biserver.key'],
      default => undef
    }
  }

  nginx::resource::proxy_redirect { 'map biserver root':
    vhost    => 'biserver',
    location => 'biserver-default',
    ssl      => 'true',
    from     => "http://${vhost_name}/",
    to       => '$scheme://$http_host/';
  }

  if ($ssl == true) {
    if ($ssl_cert == undef) or ($ssl_key == undef) {
      fail('SSL certificate (ssl_cert) and SSL Private key (ssl_key) must be defined ')
    }

    nginx::resource::rewrite { 'redirect-biserver-to-ssl':
      vhost       => 'biserver',
      ssl         => false,
      regex       => '^/(.*)$',
      replacement => "https://${vhost_name}/\$1",
      condition   => "\$http_host = ${vhost_name}",
      description => 'Redirect to ssl site',
      flag        => 'permanent';
    }

    file {
      '/etc/nginx/ssl':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => 700;
      '/etc/nginx/ssl/biserver.key':
        source => $ssl_key,
        owner  => 'root',
        group  => 'root',
        mode   => 600;
      '/etc/nginx/ssl/biserver.crt':
        source => $ssl_cert,
        owner  => 'root',
        group  => 'root',
        mode   => 600;
    }
  }
}

