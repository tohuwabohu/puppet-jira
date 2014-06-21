require 'spec_helper'

describe 'jira' do
  let(:title) { 'jira' }
  let(:archive_name) { 'atlassian-jira-6.2' }
  let(:dbconfig_xml) { '/var/lib/jira/dbconfig.xml' }
  let(:server_xml) { '/opt/atlassian-jira-6.2-standalone/conf/server.xml' }
  let(:setenv_sh) { '/opt/atlassian-jira-6.2-standalone/bin/setenv.sh' }

  describe 'by default' do
    let(:params) { {} }

    specify { should contain_archive(archive_name) }
    specify { should contain_user('jira') }
    specify { should contain_service('jira').with_ensure('running').with_enable(true) }
    specify { should contain_file(server_xml).with_content(/protocol="AJP\/1.3"/) }
    specify { should contain_file(server_xml).with_content(/port="8009"/) }
    specify { should contain_file(setenv_sh).with_content(/JIRA_MAX_PERM_SIZE=384m/) }
    specify { should contain_file(setenv_sh).without_content(/-Datlassian.plugins.enable.wait=/) }
    specify { should contain_service('jira').with_require('Package[sun-java6-jdk]') }
    specify { should contain_cron('cleanup-jira-export').with_command('find /var/lib/jira/export/ -name "*.zip" -type f -mtime +7 -delete') }
    specify { should contain_file(dbconfig_xml) }
    specify { should contain_file(dbconfig_xml).with_content(/<url>jdbc:postgresql:\/\/localhost:5432\/jira<\/url>/) }
    specify { should contain_file(dbconfig_xml).with_content(/<database-type>postgres72<\/database-type>/) }
    specify { should contain_file(dbconfig_xml).with_content(/<driver-class>org.postgresql.Driver<\/driver-class>/) }
    specify { should contain_file(dbconfig_xml).with_content(/<username>jira<\/username>/) }
    specify { should contain_file(dbconfig_xml).with_content(/<password>secret<\/password>/) }
  end

  describe 'should not accept empty hostname' do
    let(:params) { {:hostname => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /hostname/)
    end
  end

  describe 'with version => 1.0.0' do
    let(:params) { {:version => '1.0.0'} }

    specify { should contain_archive('atlassian-jira-1.0.0') }
  end

  describe 'should not accept empty version' do
    let(:params) { {:version => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /version/)
    end
  end

  describe 'should accept empty md5sum' do
    let(:params) { {:md5sum => ''} }

    specify { should contain_archive(archive_name).with_digest_string('') }
  end

  describe 'with custom md5sum' do
    let(:params) { {:md5sum => 'beef'} }

    specify { should contain_archive(archive_name).with_digest_string('beef') }
  end

  describe 'should not accept empty service_disabled' do
    let(:params) { {:service_disabled => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /service_disabled/)
    end
  end

  describe 'should not accept invalid service_disabled' do
    let(:params) { {:service_disabled => 'invalid'} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /service_disabled/)
    end
  end

  describe 'with service_disabled => true' do
    let(:params) { {:service_disabled => true} }

    specify { should contain_service('jira').with_ensure('stopped').with_enable(false) }
  end

  describe 'with service_disabled => false' do
    let(:params) { {:service_disabled => false} }

    specify { should contain_service('jira').with_ensure('running').with_enable(true) }
  end

  describe 'should not accept empty service_name' do
    let(:params) { {:service_name => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /service_name/)
    end
  end

  describe 'with custom service_name' do
    let(:params) { {:service_name => 'jdoe'} }

    specify { should contain_user('jdoe') }
    specify { should contain_service('jdoe') }
  end

  describe 'should not accept invalid service_uid' do
    let(:params) { {:service_uid => 'invalid'} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /service_uid/)
    end
  end

  describe 'should accept valid service_uid' do
    let(:params) { {:service_uid => 500} }

    specify { should contain_user('jira').with_uid(500) }
  end

  describe 'should accept empty service_uid' do
    let(:params) { {:service_gid => ''} }

    specify { should contain_user('jira').with_uid('') }
  end

  describe 'should not accept invalid service_gid' do
    let(:params) { {:service_gid => 'invalid'} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /service_gid/)
    end
  end

  describe 'should accept valid service_gid' do
    let(:params) { {:service_gid => 500} }

    specify { should contain_user('jira').with_gid(500) }
  end

  describe 'should accept empty service_gid' do
    let(:params) { {:service_gid => ''} }

    specify { should contain_user('jira').with_gid('') }
  end

  describe 'with default HTTP address and port' do
    let(:params) { {:protocols => ['http']} }

    specify { should contain_file(server_xml).with_content(/address="127.0.0.1"/) }
    specify { should contain_file(server_xml).with_content(/port="8080"/) }
  end

  describe 'with empty HTTP address' do
    let(:params) { {:http_address => '', :protocols => ['http']} }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with wildcard HTTP address' do
    let(:params) { {:http_address => '*', :protocols => ['http']} }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with custom HTTP address' do
    let(:params) { {:http_address => '1.2.3.4', :protocols => ['http']} }

    specify { should contain_file(server_xml).with_content(/address="1.2.3.4"/) }
  end

  describe 'with custom HTTP port' do
    let(:params) { {:http_port => '80', :protocols => ['http']} }

    specify { should contain_file(server_xml).with_content(/port="80"/) }
  end

  describe 'with custom AJP port' do
    let(:params) { {:ajp_port => 1234, :protocols => ['ajp']} }

    specify { should contain_file(server_xml).with_content(/port="1234"/) }
  end

  describe 'empty AJP address' do
    let(:params) { {:ajp_address => '', :protocols => ['ajp']} }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with wildcard AJP address' do
    let(:params) { {:ajp_address => '*', :protocols => ['ajp']} }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with custom AJP address' do
    let(:params) { {:ajp_address => '1.2.3.4', :protocols => ['ajp']} }

    specify { should contain_file(server_xml).with_content(/protocol="AJP\/1.3"/) }
    specify { should contain_file(server_xml).with_content(/address="1.2.3.4"/) }
  end

  describe 'with custom java opts' do
    let(:params) { {:java_opts => '-Xms512m -Xmx1024m'} }

    specify { should contain_file(setenv_sh).with_content(/-Xms512m -Xmx1024m/) }
  end

  describe 'should not accept empty java opts' do
    let(:params) { {:java_opts => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /java_opts/)
    end
  end

  describe 'with java_permgen => 256m' do
    let(:params) { {:java_permgen => '256m'} }

    specify { should contain_file(setenv_sh).with_content(/JIRA_MAX_PERM_SIZE=256m/) }
  end

  describe 'depends on custom java package' do
    let(:params) { {:java_package => 'custom-java-jdk'} }

    specify { should contain_service('jira').with_require('Package[custom-java-jdk]') }
  end

  describe 'with plugin_startup_timeout => 600' do
    let(:params) { { :plugin_startup_timeout => 600} }

    specify { should contain_file(setenv_sh).with_content(/-Datlassian.plugins.enable.wait=600/) }
  end

  describe 'should not accept empty db_url' do
    let(:params) { {:db_url => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /db_url/)
    end
  end

  describe 'should not accept empty db_type' do
    let(:params) { {:db_type => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /db_type/)
    end
  end

  describe 'should not accept empty db_driver' do
    let(:params) { {:db_driver => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /db_driver/)
    end
  end

  describe 'should not accept empty db_username' do
    let(:params) { {:db_username => ''} }

    specify do
      expect { should contain_class('jira') }.to raise_error(Puppet::Error, /db_username/)
    end
  end

  describe 'should accept empty db_password' do
    let(:params) { {:db_password => ''} }

    specify { should contain_file(dbconfig_xml).with_content(/<password><\/password>/) }
  end
end
