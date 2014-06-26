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
  $hostname               = $jira::params::hostname,
  $version                = $jira::params::version,

  $service_name           = $jira::params::service_name,
  $service_uid            = $jira::params::service_uid,
  $service_gid            = $jira::params::service_gid,
  $service_disabled       = $jira::params::service_disabled,

  $md5sum                 = $jira::params::md5sum,
  $package_dir            = $jira::params::package_dir,
  $install_dir            = $jira::params::install_dir,
  $data_dir               = $jira::params::data_dir,

  $db_url                 = $jira::params::db_url,
  $db_type                = $jira::params::db_type,
  $db_driver              = $jira::params::db_driver,
  $db_username            = $jira::params::db_username,
  $db_password            = $jira::params::db_password,

  $http_address           = $jira::params::http_address,
  $http_port              = $jira::params::http_port,
  $ajp_address            = $jira::params::ajp_address,
  $ajp_port               = $jira::params::ajp_port,
  $protocols              = $jira::params::protocols,

  $java_opts              = $jira::params::java_opts,
  $java_permgen           = $jira::params::java_permgen,
  $java_package           = $jira::params::java_package,
  $plugin_startup_timeout = $jira::params::plugin_startup_timeout,

  $purge_backups_after    = $jira::params::purge_backups_after
) inherits jira::params {

  if empty($hostname) {
    fail('Class[Jira]: hostname must not be empty')
  }
  if empty($version) {
    fail('Class[Jira]: version must not be empty')
  }
  if empty($service_name) {
    fail('Class[Jira]: service_name must not be empty')
  }
  if !empty($service_uid) and !is_integer($service_uid) {
    fail("Class[Jira]: service_uid must be an interger, got '${service_uid}'")
  }
  if !empty($service_gid) and !is_integer($service_gid) {
    fail("Class[Jira]: service_gid must be an interger, got '${service_gid}'")
  }
  if !is_bool($service_disabled) {
    fail("Class[Jira]: service_disabled must be either true or false, got '${$service_disabled}'")
  }
  validate_absolute_path($package_dir)
  validate_absolute_path($install_dir)
  validate_absolute_path($data_dir)
  if empty($db_url) {
    fail('Class[Jira]: db_url must not be empty')
  }
  if empty($db_type) {
    fail('Class[Jira]: db_type must not be empty')
  }
  if empty($db_driver) {
    fail('Class[Jira]: db_driver must not be empty')
  }
  if empty($db_username) {
    fail('Class[Jira]: db_username must not be empty')
  }
  if empty($java_opts) {
    fail('Class[Jira]: java_opts must not be empty')
  }
  if !empty($purge_backups_after) and !is_integer($purge_backups_after) {
    fail("Class[Jira]: purge_backups_after must be an integer, got '${purge_backups_after}'")
  }

  class { 'jira::install': } ->
  class { 'jira::config': } ~>
  class { 'jira::service': }
}
