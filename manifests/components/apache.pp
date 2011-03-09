class apache {
  package { apache2: ensure => installed }

  service {
    apache2:
    enable => true,
    ensure => running
  }
}
