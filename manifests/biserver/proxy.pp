class pentaho::biserver::proxy($vhost_name = 'pentaho', $vhost_port = 80) {
  include nginx
  nginx::resource::upstream { 'bi-server':
    ensure  => present,
    members => [
      'localhost:8080',
    ],
  }
  nginx::resource::vhost { "biserver":
    server_name => $vhost_name,
    listen_port => $vhost_port,
    ensure   => present,
    proxy  => 'http://bi-server',
  }
}

