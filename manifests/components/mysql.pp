class mysql {
  $packages = [ "mysql-client", "mysql-common", "mysql-server" ]
  
  package { $packages:
    ensure => installed,
  }
  
  service { mysql:
    enable    => true,
    ensure    => running,
    subscribe => Package[mysql-server],
  }
  exec { "create-database":
    command => "/usr/bin/mysqladmin create drupal7"

  }
}
