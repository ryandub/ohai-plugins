require 'spec_helper'

apache2 = OHAI['apache2']
platform = OHAI['platform']
platform_family = OHAI['platform_family']
platform_version = OHAI['platform_version'].to_f

describe "Apache2 Plugin" do

  if platform_family == 'debian'
    apache_user = 'www-data'
    apache_bin = '/usr/sbin/apache2'
    apache_config_path = '/etc/apache2'
    apache_config_file = '/etc/apache2/apache2.conf'
    if platform == 'ubuntu' and platform_version >= 13.10
      apache_mpm = 'event'
    else
      apache_mpm = 'worker'
    end
  elsif platform_family == 'rhel'
    apache_user = 'apache'
    apache_bin = '/usr/sbin/httpd'
    apache_config_path = '/etc/httpd'
    apache_config_file = '/etc/httpd/conf/httpd.conf'
    apache_mpm = 'prefork'
  end

  it 'should have the binary in the right location' do
    expect(apache2['bin']).to eql(apache_bin)
  end

  it 'should have clients > 1' do
    expect(apache2['clients'].to_i).to be > 1
  end

  it 'should report a user' do
    expect(apache2['user']).to eql(apache_user)
  end

  it 'should report a mpm' do
    expect(apache2['mpm']).to eql(apache_mpm)
  end

  it 'should report a config_path' do
    expect(apache2['config_path']).to eql(apache_config_path)
  end

  it 'should report a config_file' do
    expect(apache2['config_file']).to eql(apache_config_file)
  end

  it 'should report valid syntax' do
    expect(apache2['syntax_ok']).to eql(true)
  end

end