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

  $service_script = $jira::params::service_script

  service { 'jira':
    ensure   => $manage_service_ensure,
    enable   => $manage_service_enable,
    provider => base,
    start    => "${service_script} start",
    restart  => "${service_script} restart",
    stop     => "${service_script} stop",
    status   => "${service_script} status",
    require  => Package[$jira::java_package],
  }
}
