# Class: jira::config
#
# Configure the jira module.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class jira::config inherits jira {

  $application_dir = $jira::application_dir
  $data_dir = $jira::data_dir
  $plugin_startup_timeout = $jira::plugin_startup_timeout

  file { "${application_dir}/conf/server.xml":
    content => template('jira/server.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${application_dir}/bin/setenv.sh":
    content => template('jira/setenv.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${application_dir}/bin/user.sh":
    content => template('jira/user.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${data_dir}/dbconfig.xml":
    content => template('jira/dbconfig.postgresql.xml.erb'),
    owner   => $jira::service_name,
    group   => $jira::service_name,
    mode    => '0600',
  }
}
