class php {
  $packages = [ "php5", "php5-mysql", "php5-gd", "php-apc"]

  package { $packages:
    ensure => installed,
  }
}
