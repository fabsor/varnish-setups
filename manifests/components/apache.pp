class apache {
  $packages = [ "apache2" ]
  $vhosts = [ "varnish.test.org" ]
  $mods = [ "rewrite" ]
  $files = ["apache2.conf", "ports.conf", "httpd.conf", "conf.d/charset", 
  "conf.d/default", "conf.d/log", "conf.d/security", 
  "conf.d/ssl", "conf.d/tweaks"]
  
  package { $packages:
    ensure => installed,
  }
  
  service { apache2:
    enable  => true,
    ensure  => running,
    require => Package["apache2"]
  }
  
  config_file { $files:
    require => Package["apache2"]
  }
  
  a2mod { $mods:
    require => Package["apache2"]
  }
  
  
  vhost { $vhosts:
    require => Package["apache2"]
  }
  
  define config_file() {
    file { "/etc/apache2/$name":
      owner  => root,
      group  => root,
      mode   => 0444,
      source => "/srv/varnish/config/apache/$name",
    }
  }
  
  define a2mod() {
    exec { "enable-$name":
      command => "/usr/sbin/a2enmod $name",
      notify => Service["apache2"],
    }
  }
  
  define vhost() {
    file { "/etc/apache2/sites-available/$name":
      owner  => root,
      group  => root,
      mode   => 0444,
      source => "/srv/varnish/config/apache/vhosts/$name",
      /* notify => Service["apache2"], */
      before => File["/etc/apache2/sites-enabled/$name"],
    }
    file { "/etc/apache2/sites-enabled/$name" :
      owner  => root,
      group  => root,
      mode   => 0444,
      ensure => "/etc/apache2/sites-available/$name",
      notify => Service["apache2"],
    }
  }
}
