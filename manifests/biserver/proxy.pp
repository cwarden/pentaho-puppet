class pentaho::biserver::proxy {
  include nginx
  nginx::resource::upstream { 'bi-server':
    ensure  => present,
    members => [
      'localhost:8080',
    ],
  }
  nginx::resource::vhost { 'reporting.swellpath.com':
    ensure   => present,
    proxy  => 'http://bi-server',
  }
}

