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
  $hostname               = params_lookup('hostname'),
  $version                = params_lookup('version'),

  $service_name           = params_lookup('service_name'),
  $service_uid            = params_lookup('service_uid'),
  $service_gid            = params_lookup('service_gid'),
  $service_disabled       = params_lookup('service_disabled'),

  $md5sum                 = params_lookup('md5sum'),
  $package_dir            = params_lookup('package_dir'),
  $install_dir            = params_lookup('install_dir'),
  $data_dir               = params_lookup('data_dir'),

  $db_url                 = params_lookup('db_url'),
  $db_type                = params_lookup('db_type'),
  $db_driver              = params_lookup('db_driver'),
  $db_username            = params_lookup('db_username'),
  $db_password            = params_lookup('db_password'),

  $http_address           = params_lookup('http_address'),
  $http_port              = params_lookup('http_port'),
  $ajp_address            = params_lookup('ajp_address'),
  $ajp_port               = params_lookup('ajp_port'),
  $protocols              = params_lookup('protocols'),

  $java_opts              = params_lookup('java_opts'),
  $java_permgen           = params_lookup('java_permgen'),
  $java_package           = params_lookup('java_package'),
  $plugin_startup_timeout = params_lookup('plugin_startup_timeout'),

  $purge_backups_after    = params_lookup('purge_backups_after')
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
