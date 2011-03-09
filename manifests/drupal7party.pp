exec { "apt-get update":
  command => "/usr/bin/apt-get update",
}

Package {
  require => Exec["apt-get update"]
}


import 'components/*.pp'
import 'config/*.pp'

include mysql
include php
include apache
include apache2config
