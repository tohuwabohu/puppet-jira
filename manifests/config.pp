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
class jira::config($application_dir, $data_dir) {
  validate_absolute_path($application_dir)
  validate_absolute_path($data_dir)

  file { "${application_dir}/conf/server.xml":
    content => template('jira/server.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['jira'],
  }

  $plugin_startup_timeout = $jira::plugin_startup_timeout
  file { "${application_dir}/bin/setenv.sh":
    content => template('jira/setenv.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['jira'],
  }

  file { "${application_dir}/bin/user.sh":
    content => template('jira/user.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['jira'],
  }

  file { "${data_dir}/dbconfig.xml":
    content => template('jira/dbconfig.postgresql.xml.erb'),
    owner   => $jira::process,
    group   => $jira::process,
    mode    => '0600',
    notify  => Service['jira'],
  }
}