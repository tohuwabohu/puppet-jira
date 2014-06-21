# Class: jira
#
# Manage an Atlassian JIRA installation.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class jira (
  $hostname = params_lookup('hostname'),
  $disable = params_lookup('disable'),
  $version = params_lookup('version'),
  $md5 = params_lookup('md5'),
  $process = params_lookup('process'),

  $package_dir = params_lookup('package_dir'),
  $install_dir = params_lookup('install_dir'),
  $data_dir = params_lookup('data_dir'),

  $db_url = params_lookup('db_url'),
  $db_driver = params_lookup('db_driver'),
  $db_username = params_lookup('db_username'),
  $db_password = params_lookup('db_password'),

  $http_address = params_lookup('http_address'),
  $http_port = params_lookup('http_port'),
  $ajp_address = params_lookup('ajp_address'),
  $ajp_port = params_lookup('ajp_port'),
  $protocols = params_lookup('protocols'),

  $java_opts = params_lookup('java_opts'),
  $java_permgen = params_lookup('java_permgen'),
  $java_package = params_lookup('java_package'),
  $plugin_startup_timeout = params_lookup('plugin_startup_timeout')
) inherits jira::params {
  validate_string($md5)
  validate_string($process)
  validate_absolute_path($package_dir)
  validate_absolute_path($install_dir)
  validate_absolute_path($data_dir)
  validate_string($db_url)
  validate_string($db_driver)
  validate_string($db_username)
  validate_string($db_password)
  validate_string($java_opts)

  $bool_disable = any2bool($disable)

  $manage_service_ensure = $jira::bool_disable ? {
    true => 'stopped',
    default => 'running',
  }

  $manage_service_enable = $jira::bool_disable ? {
    true    => false,
    default => true,
  }

  $application_dir = $::operatingsystem ? {
    default => "${install_dir}/atlassian-jira-${jira::version}-standalone",
  }

  class { 'jira::package':
    version         => $jira::version,
    md5             => $jira::md5,
    install_dir     => $jira::install_dir,
    package_dir     => $jira::package_dir,
    application_dir => $jira::application_dir,
    data_dir        => $jira::data_dir,
    process         => $jira::process,
    require         => Package[$java_package],
  }

  class { 'jira::config':
    application_dir => $jira::application_dir,
    data_dir        => $jira::data_dir,
    require         => Class['jira::package'],
  }

  service { 'jira':
    ensure   => $manage_service_ensure,
    enable   => $manage_service_enable,
    provider => base,
    start    => '/etc/init.d/jira start',
    restart  => '/etc/init.d/jira restart',
    stop     => '/etc/init.d/jira stop',
    status   => '/etc/init.d/jira status',
    require  => Class['jira::config'],
  }
}