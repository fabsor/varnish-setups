class php {
  $packages = [ "php5", "php5-mysql", "php5-gd"]

  package { $packages:
    ensure => installed,
  }
}
