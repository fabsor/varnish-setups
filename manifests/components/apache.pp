class apache {
  package { httpd: ensure => installed }

  service {
    httpd:
    enable => true,
    ensure => running
  }

  file { "/etc/httpd/conf/httpd.conf":
      owner => root,
      group => root,
      mode => 660,
      source => "/etc/puppet/files/etc/httpd/conf/httpd.conf",
      require => [ Package[httpd] ]
  }

}
