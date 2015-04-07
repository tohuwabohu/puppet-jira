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

  $current_dir = $jira::install::current_dir
  $data_dir = $jira::data_dir
  $plugin_startup_timeout = $jira::plugin_startup_timeout
  $service_name = $jira::service_name

  file { "${current_dir}/conf/server.xml":
    content => template('jira/server.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file_line { "${current_dir}/bin/setenv.sh":
    path => "${current_dir}/bin/setenv.sh",
    line => '. `dirname $0`/setenv2.sh',
  }

  file { "${current_dir}/bin/setenv2.sh":
    content => template('jira/setenv2.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
  }

  file { "${current_dir}/bin/user.sh":
    content => template('jira/user.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${data_dir}/dbconfig.xml":
    content => template('jira/dbconfig.postgresql.xml.erb'),
    owner   => $service_name,
    group   => $service_name,
    mode    => '0600',
  }
}
