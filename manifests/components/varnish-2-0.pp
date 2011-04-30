class varnish20 {
  $packages = [ "subversion", 
   "dpkg-dev", "build-essential", 
   "debhelper", "automake1.9", "libncurses-dev", "xsltproc", "libtool" ]
  
  package { $packages:
    ensure => installed,
  }
  
  exec { "install-varnish":
    command => "/srv/varnish/bin/install-varnish",
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
    source => "/srv/varnish/config/varnish/drupal-2-0.vcl",
  }
}
