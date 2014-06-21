require 'spec_helper'

describe 'jira' do
  let(:title) {'jira'}
  let(:facts) { {:postgres_default_version => '9.2', :operatingsystem => 'Debian', :osfamily => 'Debian'} }

  describe 'standard installation' do
    let(:params) { {} }

    it { should contain_archive('atlassian-jira-6.2') }
    it { should contain_service('jira').with_ensure('running').with_enable(true) }
  end

  describe 'custom version' do
    let(:params) { {:version => '1.0.0'} }

    it { should contain_archive('atlassian-jira-1.0.0') }
  end

  describe 'disable service' do
    let(:params) { {:disable => true} }

    it { should contain_service('jira').with_ensure('stopped').with_enable(false) }
  end

  describe 'default HTTP address and port' do
    let(:params) { {:protocols => ['http']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/address="127.0.0.1"/)
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="8080"/)
    end
  end

  describe 'empty HTTP address' do
    let(:params) { {:http_address => '', :protocols => ['http']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/)
    end
  end

  describe 'wildcard HTTP address' do
    let(:params) { {:http_address => '*', :protocols => ['http']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/)
    end
  end

  describe 'custom HTTP address' do
    let(:params) { {:http_address => '1.2.3.4', :protocols => ['http']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/address="1.2.3.4"/)
    end
  end

  describe 'custom HTTP port' do
    let(:params) { {:http_port => '80', :protocols => ['http']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="80"/)
    end
  end

  describe 'custom AJP port' do
    let(:params) { {:ajp_port => 1234, :protocols => ['ajp']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="1234"/)
    end
  end

  describe 'empty AJP address' do
    let(:params) { {:ajp_address => '', :protocols => ['ajp']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/)
    end
  end

  describe 'wildcard AJP address' do
    let(:params) { {:ajp_address => '*', :protocols => ['ajp']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/)
    end
  end

  describe 'custom AJP address' do
    let(:params) { {:ajp_address => '1.2.3.4', :protocols => ['ajp']} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/protocol="AJP\/1.3"/)
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/address="1.2.3.4"/)
    end
  end

  describe 'default AJP address and port' do
    let(:params) { {} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/protocol="AJP\/1.3"/)
      should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="8009"/)
    end
  end

  describe 'custom java opts' do
    let(:params) { {:java_opts => '-Xms512m -Xmx1024m'} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/-Xms512m -Xmx1024m/)
    end
  end
  describe 'by default' do
    let(:params) { {} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/JIRA_MAX_PERM_SIZE=384m/)
    end
  end

  describe 'with java_permgen => 256m' do
    let(:params) { {:java_permgen => '256m'} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/JIRA_MAX_PERM_SIZE=256m/)
    end
  end

  describe 'depends on sun-java6-jdk' do
    let(:params) { {} }

    it { should contain_class("jira::package").with_require('Package[sun-java6-jdk]') }
  end

  describe 'depends on custom java package' do
    let(:params) { {:java_package => 'custom-java-jdk'} }

    it { should contain_class("jira::package").with_require('Package[custom-java-jdk]') }
  end

  describe 'by default' do
    let(:params) { {} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').without_content(/-Datlassian.plugins.enable.wait=/)
    end
  end

  describe 'with plugin_startup_timeout => 600' do
    let(:params) { { :plugin_startup_timeout => 600} }

    it do
      should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/-Datlassian.plugins.enable.wait=600/)
    end
  end

  describe 'configures cron job to clean up export directory' do
    let(:params) { {} }

    it { should contain_cron('cleanup-jira-export').with_command('find /data/jira/export/ -name "*.zip" -type f -mtime +7 -delete') }
  end

  describe 'creates database configuration in the data dir' do
    let(:params) { {} }

    it { should contain_file('/data/jira/dbconfig.xml') }
  end
end
