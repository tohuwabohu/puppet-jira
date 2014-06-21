# Class: jira::package
#
# Represents the jira package and resources created during the installation.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class jira::package($version, $md5, $install_dir, $package_dir, $application_dir, $data_dir, $process) {
  validate_string($md5)
  validate_absolute_path($install_dir)
  validate_absolute_path($package_dir)
  validate_absolute_path($application_dir)
  validate_absolute_path($data_dir)
  validate_string($process)

  $pid_directory = $::operatingsystem ? {
    default => "/var/run/${process}",
  }

  $pid_file = $::operatingsystem ? {
    default => "${pid_directory}/${process}.pid",
  }

  archive { "atlassian-jira-${version}":
    ensure        => present,
    digest_string => $md5,
    url           => "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${version}.tar.gz",
    target        => $install_dir,
    src_target    => $package_dir,
    root_dir      => "atlassian-jira-${version}-standalone",
    timeout       => 600,
    require       => [File[$install_dir], File[$package_dir]],
  }

  file { $application_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Archive["atlassian-jira-${version}"],
  }

  file { ["${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work",
    "${application_dir}/conf/Catalina"]:
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

  file { $pid_directory:
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
