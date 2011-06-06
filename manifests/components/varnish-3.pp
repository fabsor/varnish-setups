class varnish3 {
  $packages = ["curl"]  
  package { $packages:
    ensure => installed,
  }
  
  exec { "install-varnish":
    command => "/srv/varnish/bin/install-varnish3",
    unless => "/usr/bin/test -f /etc/init.d/varnish"
  }
  
  service { varnish:
    enable  => true,
    ensure  => running,
  }
  
  file { "/etc/varnish/default.vcl":
    owner  => root,
    group  => root,
    mode   => 0444,
    source => "/srv/varnish/config/varnish/drupal-2-1.vcl",
  }
}
