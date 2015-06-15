require 'spec_helper_acceptance'
include TestDependencies

describe 'by default' do
  let(:manifest) do
    <<-EOS
      class { 'jira':
        java_package_ensure => installed,
      }
    EOS
  end

  specify 'should provision with no errors' do
    apply_manifest(with_test_dependencies(manifest), :catch_failures => true)
  end

  specify 'should be idempotent' do
    apply_manifest(with_test_dependencies(manifest), :catch_changes => true)
  end

  describe user('jira') do
    specify { should exist }
  end

  describe group('jira') do
    specify { should exist }
  end

  describe service('jira') do
    specify { should be_running }
  end
end
