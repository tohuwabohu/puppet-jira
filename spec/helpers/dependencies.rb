module TestDependencies
  def with_test_dependencies(test_manifest)
    setup_manifest + test_manifest
  end

  def setup_manifest
    <<-EOS
      $required_directories = [
        '/opt',
        '/var/cache/puppet',
        '/var/cache/puppet/archives',
      ]

      file { $required_directories:
        ensure => directory,
      }
    EOS
  end
end
