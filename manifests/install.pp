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

  $version = $jira::version
  $archive_name = "atlassian-jira-${version}"
  $archive_root_dir = "${archive_name}-standalone"
  $archive_md5sum = $jira::md5sum
  $archive_url = "http://www.atlassian.com/software/jira/downloads/binary/${archive_name}.tar.gz"

  $application_dir = "${jira::install_dir}/${archive_root_dir}"
  $current_dir = "${jira::install_dir}/atlassian-jira-current"
  $data_dir = $jira::data_dir
  $backup_dir = "${data_dir}/export"

  $service_name = $jira::service_name
  $pid_directory = "${jira::params::run_dir}/${service_name}"
  $pid_file = "${pid_directory}/${service_name}.pid"
  $work_dirs = [
    "${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work",
    "${application_dir}/conf/Catalina"
  ]
  $cron_ensure = empty($jira::purge_backups_after) ? {
    true    => absent,
    default => file,
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

  archive { $archive_name:
    ensure           => present,
    digest_string    => $archive_md5sum,
    url              => $archive_url,
    target           => $jira::install_dir,
    src_target       => $jira::package_dir,
    root_dir         => $archive_root_dir,
    follow_redirects => true,
    timeout          => 600,
    require          => [
      File[$jira::install_dir],
      File[$jira::package_dir]
    ],
  }

  file { $application_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Archive[$archive_name],
  }

  file { $current_dir:
    ensure => link,
    target => $application_dir,
    notify => Class['jira::service'],
  }

  file { $work_dirs:
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0644',
  }

  file { $jira::params::service_script:
    ensure  => file,
    content => template('jira/jira.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { $pid_directory:
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0755',
  }

  file { $backup_dir:
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0644'
  }

  file { '/etc/cron.daily/purge-old-jira-backups':
    ensure  => $cron_ensure,
    content => "#!/bin/bash\n/usr/bin/find ${backup_dir}/ -name \"*.zip\" -type f -mtime +${jira::purge_backups_after} -delete",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$backup_dir],
  }
}
