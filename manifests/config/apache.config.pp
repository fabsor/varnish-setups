class apache2config {
  exec { "ln -s /srv/vhosts sites-enabled":
    unless => test "/bin/readlink /srv/vhosts" = "/srv/vhosts",
    notify => Exec["reload-apache2"],
    require => Package[$require],
  }

   # Notify this when apache needs a reload. This is only needed when
   # sites are added or removed, since a full restart then would be
   # a waste of time. When the module-config changes, a force-reload is
   # needed.
   exec { "reload-apache2":
      command => "/etc/init.d/apache2 reload",
      refreshonly => true,
   }

   exec { "force-reload-apache2":
      command => "/etc/init.d/apache2 force-reload",
      refreshonly => true,
   }
}
