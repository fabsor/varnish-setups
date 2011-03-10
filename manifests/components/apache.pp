class apache {
  $packages = [ "apache2" ]
  $vhosts = [ "drupal7.party.se" ]
  
  package { $packages:
    ensure => installed,
  }
  
  service { apache2:
    enable  => true,
    ensure  => running,
    require => Package["apache2"]
  }
  
  vhost { $vhosts:
    /* require => Package["apache2"] */
  }
  
  define vhost() {
    file { "/etc/apache2/sites-available/$name":
      owner  => root,
      group  => root,
      mode   => 0444,
      source => "/srv/www/party/vhosts/$name",
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
