class apache2config {
  
  exec { "add-available-site":
    cwd => "/etc/apache2/sites-available",
    command => "/bin/ln -s /srv/www/drupal7party/vhosts/drupal7.party.se",
    unless => "/usr/bin/test -L drupal7.party.se",
  }
  
  exec { "add-enabled-site":
    cwd => "/etc/apache2/sites-enabled",
    command => "/usr/sbin/a2ensite drupal7.party.se",
    unless => "/usr/bin/test -L drupal7.party.se",
    notify => Exec["reload-apache2"],
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
