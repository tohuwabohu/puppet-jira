# Class: jira::params
#
# Default configuration for the jira class.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class jira::params {
  $hostname = $::fqdn
  $version = '6.2'
  $md5sum = '71a521cd983bc0892dc64027456cea25'
  $process = 'jira'

  $db_url = 'jdbc:postgresql://localhost:5432/jira'
  $db_type = 'postgres72'
  $db_driver = 'org.postgresql.Driver'
  $db_username = 'jira'
  $db_password = 'secret'

  $http_address = '127.0.0.1'
  $http_port = 8080
  $ajp_address = '127.0.0.1'
  $ajp_port = 8009
  $protocols = ['http', 'ajp']

  $java_opts = '-Xms384m -Xmx768m'
  $java_permgen = '384m'
  $java_package = $::operatingsystem ? {
    default => 'sun-java6-jdk',
  }
  $plugin_startup_timeout = undef

  $package_dir = $::operatingsystem ? {
    default => '/var/cache/puppet/archives',
  }

  $install_dir = $::operatingsystem ? {
    default => '/opt',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/jira',
  }

  $pid_directory = $::operatingsystem ? {
    default => "/var/run/${process}",
  }

  $service_name = 'jira'
  $service_uid = undef
  $service_gid = undef
  $service_disabled = false
  $service_script = $::osfamily ? {
    default => '/etc/init.d/jira',
  }
}
