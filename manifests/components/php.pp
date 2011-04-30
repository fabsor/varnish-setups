class php {
  $packages = [ "php5", "php5-mysql", "php5-gd", "php-apc", "php5-curl"]

  package { $packages:
    ensure => installed,
  }
}
