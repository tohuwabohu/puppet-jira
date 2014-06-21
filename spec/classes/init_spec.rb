require 'spec_helper'

describe 'jira' do
  let(:title) {'jira'}

  describe 'by default' do
    let(:params) { {} }

    specify { should contain_archive('atlassian-jira-6.2') }
    specify { should contain_service('jira').with_ensure('running').with_enable(true) }
    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/protocol="AJP\/1.3"/) }
    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="8009"/) }
    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/JIRA_MAX_PERM_SIZE=384m/) }
    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').without_content(/-Datlassian.plugins.enable.wait=/) }
    specify { should contain_class("jira::package").with_require('Package[sun-java6-jdk]') }
    specify { should contain_cron('cleanup-jira-export').with_command('find /data/jira/export/ -name "*.zip" -type f -mtime +7 -delete') }
    specify { should contain_file('/data/jira/dbconfig.xml') }
  end

  describe 'with version => 1.0.0' do
    let(:params) { {:version => '1.0.0'} }

    specify { should contain_archive('atlassian-jira-1.0.0') }
  end

  describe 'with disable => true' do
    let(:params) { {:disable => true} }

    specify { should contain_service('jira').with_ensure('stopped').with_enable(false) }
  end

  describe 'with default HTTP address and port' do
    let(:params) { {:protocols => ['http']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/address="127.0.0.1"/) }
    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="8080"/) }
  end

  describe 'with empty HTTP address' do
    let(:params) { {:http_address => '', :protocols => ['http']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/) }
  end

  describe 'with wildcard HTTP address' do
    let(:params) { {:http_address => '*', :protocols => ['http']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/) }
  end

  describe 'with custom HTTP address' do
    let(:params) { {:http_address => '1.2.3.4', :protocols => ['http']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/address="1.2.3.4"/) }
  end

  describe 'with custom HTTP port' do
    let(:params) { {:http_port => '80', :protocols => ['http']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="80"/) }
  end

  describe 'with custom AJP port' do
    let(:params) { {:ajp_port => 1234, :protocols => ['ajp']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/port="1234"/) }
  end

  describe 'empty AJP address' do
    let(:params) { {:ajp_address => '', :protocols => ['ajp']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/) }
  end

  describe 'with wildcard AJP address' do
    let(:params) { {:ajp_address => '*', :protocols => ['ajp']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').without_content(/address=/) }
  end

  describe 'with custom AJP address' do
    let(:params) { {:ajp_address => '1.2.3.4', :protocols => ['ajp']} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/protocol="AJP\/1.3"/) }
    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/conf/server.xml').with_content(/address="1.2.3.4"/) }
  end

  describe 'with custom java opts' do
    let(:params) { {:java_opts => '-Xms512m -Xmx1024m'} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/-Xms512m -Xmx1024m/) }
  end

  describe 'with java_permgen => 256m' do
    let(:params) { {:java_permgen => '256m'} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/JIRA_MAX_PERM_SIZE=256m/) }
  end

  describe 'depends on custom java package' do
    let(:params) { {:java_package => 'custom-java-jdk'} }

    specify { should contain_class("jira::package").with_require('Package[custom-java-jdk]') }
  end

  describe 'with plugin_startup_timeout => 600' do
    let(:params) { { :plugin_startup_timeout => 600} }

    specify { should contain_file('/opt/atlassian-jira-6.2-standalone/bin/setenv.sh').with_content(/-Datlassian.plugins.enable.wait=600/) }
  end
end
