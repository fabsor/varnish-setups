class mysql {
  package { ["mysql-client", "mysql-common", "mysql-server"]:
    ensure => installed
  }
  
  service {
    mysql:
    enable => true,
    ensure => running,
    subscribe => Package[mysql-server]
  }
}
