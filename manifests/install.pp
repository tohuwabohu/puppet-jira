# Class: jira::install
#
# Installs JIRA.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class jira::install inherits jira {

  $application_dir = $jira::application_dir
  $data_dir = $jira::data_dir
  $process = $jira::process
  $pid_file = "${jira::params::pid_directory}/${process}.pid"
  $version = $jira::version
  $work_dirs = [
    "${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work",
    "${application_dir}/conf/Catalina"
  ]

  archive { "atlassian-jira-${version}":
    ensure        => present,
    digest_string => $jira::md5,
    url           => "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${version}.tar.gz",
    target        => $jira::install_dir,
    src_target    => $jira::package_dir,
    root_dir      => "atlassian-jira-${version}-standalone",
    timeout       => 600,
    require       => [
      File[$jira::install_dir],
      File[$jira::package_dir]
    ],
  }

  file { $application_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Archive["atlassian-jira-${version}"],
  }

  file { $work_dirs:
    ensure  => directory,
    owner   => $process,
    group   => $process,
    mode    => '0644',
    require => User[$process],
  }

  file { '/etc/init.d/jira':
    ensure  => file,
    content => template('jira/jira.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { $jira::params::pid_directory:
    ensure => directory,
    owner  => $process,
    group  => $process,
    mode   => '0755',
  }

  file { "${data_dir}/export":
    ensure => directory,
    owner  => $process,
    group  => $process,
    mode   => '0644'
  }

  cron { 'cleanup-jira-export':
    ensure  => present,
    command => "find ${data_dir}/export/ -name \"*.zip\" -type f -mtime +7 -delete",
    user    => 'root',
    hour    => '5',
    minute  => '0',
  }

  user { $process:
    ensure     => present,
    home       => $data_dir,
    shell      => '/bin/false',
    system     => true,
    managehome => true,
    require    => File[dirname($data_dir)],
  }
}
