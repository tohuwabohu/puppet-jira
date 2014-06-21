# Class: jira::service
#
# Manage the JIRA service.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class jira::service inherits jira {
  service { 'jira':
    ensure   => $manage_service_ensure,
    enable   => $manage_service_enable,
    provider => base,
    start    => '/etc/init.d/jira start',
    restart  => '/etc/init.d/jira restart',
    stop     => '/etc/init.d/jira stop',
    status   => '/etc/init.d/jira status',
    require  => Package[$jira::java_package],
  }
}
