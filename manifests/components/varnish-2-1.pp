class varnish {
  $packages = [ "varnish"]
  
  package { $packages:
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
    source => "/srv/varnish/config/varnish/drupal-2-1.vcl",
  }
}
