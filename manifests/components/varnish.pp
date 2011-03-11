class varnish {
  $packages = [ "varnish" ]
  
  package { varnish:
    ensure => installed,
  }
  
  service { varnish:
    enable  => true,
    ensure  => running,
    require => Package["varnish"]
  }
  
  file { "/etc/varnish/default.vcl":
    owner  => root,
    group  => root,
    mode   => 0444,
    source => "/srv/www/party/varnish/default.vcl",
  }
}