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
  $service_name = $jira::service_name
  $pid_file = "${jira::pid_directory}/${service_name}.pid"
  $version = $jira::version
  $work_dirs = [
    "${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work",
    "${application_dir}/conf/Catalina"
  ]
  $cron_ensure = empty($jira::purge_backups_after) ? {
    true    => absent,
    default => present,
  }

  group { $service_name:
    ensure => present,
    gid    => $jira::service_gid,
    system => true,
  }

  user { $service_name:
    ensure     => present,
    uid        => $jira::service_uid,
    gid        => $service_name,
    home       => $data_dir,
    shell      => '/bin/false',
    system     => true,
    managehome => true,
  }

  file { $data_dir:
    ensure  => directory,
    owner   => $service_name,
    group   => $service_name,
    mode    => '0644',
    require => User[$service_name],
  }

  archive { "atlassian-jira-${version}":
    ensure        => present,
    digest_string => $jira::md5sum,
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
    owner   => $service_name,
    group   => $service_name,
    mode    => '0644',
  }

  file { $jira::params::service_script:
    ensure  => file,
    content => template('jira/jira.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { $jira::pid_directory:
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0755',
  }

  file { "${data_dir}/export":
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0644'
  }

  cron { 'cleanup-jira-export':
    ensure  => $cron_ensure,
    command => "find ${data_dir}/export/ -name \"*.zip\" -type f -mtime +${jira::purge_backups_after} -delete",
    user    => $service_name,
    hour    => '5',
    minute  => '0',
  }
}
