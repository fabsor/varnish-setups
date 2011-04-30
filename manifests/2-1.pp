exec { "apt_update":
  command => "/usr/bin/apt-get update"
}

Package { require => Exec["apt_update"] }


import "components/*.pp"

include apache
include php
include mysql
include varnish
include hosts
