class mysql {
  $packages = [ "mysql-client", "mysql-common", "mysql-server" ]
  $databases = [ "drupal6" ]
  package { $packages:
    ensure => installed,
  }
  
  service { mysql:
    enable    => true,
    ensure    => running,
    subscribe => Package[mysql-server],
  }
  
  database { $databases:
    require => Package[mysql-server]
  }
  
  define database() {
    exec { "create-$name":
      command => "/usr/bin/mysqladmin create $name",
      unless => "/usr/bin/mysql -uroot ${name}"
    }
  }
}
