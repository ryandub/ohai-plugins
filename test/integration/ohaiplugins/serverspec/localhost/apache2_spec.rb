require 'spec_helper'

apache2 = OHAI['apache2']
platform = OHAI['platform']
platform_family = OHAI['platform_family']
platform_version = OHAI['platform_version'].to_f
fqdn = OHAI['fqdn']
docroot = '/var/www'

describe 'Apache2 Plugin' do

  if platform_family == 'debian'
    apache_name = 'apache2'
    apache_user = 'www-data'
    apache_bin = '/usr/sbin/apache2'
    apache_config_path = '/etc/apache2'
    apache_config_file = '/etc/apache2/apache2.conf'
    if platform == 'ubuntu' and platform_version >= 13.10
      apache_mpm = 'prefork'
      if platform_version >= 14.04
        docroot = '/var/www/html'
      end
    else
      apache_mpm = 'worker'
      docroot = '/var/www'
    end
    apache_mpm = 'prefork'
  elsif platform_family == 'rhel'
    apache_name = 'httpd'
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

  it 'should retrieve the vhost configuration' do
    if platform_version.to_f >= 13.10
      vhost_hash = {
        '*:80' => {
          'default' => {
            'vhost' => 'magento.example.com',
            'conf' => '/etc/apache2/sites-enabled/magento.conf:1',
            'docroot' => '/srv/magento',
            'accesslogs' => ['/var/log/apache2/magento-access.log combined'],
            'errorlog' => '/var/log/apache2/magento-error.log'
          },
          'magento.example.com' => {
            'vhost' => 'magento.example.com',
            'conf' => '/etc/apache2/sites-enabled/magento.conf:1',
            'port' => '80',
            'docroot' => '/srv/magento',
            'accesslogs' => ['/var/log/apache2/magento-access.log combined'],
            'errorlog' => '/var/log/apache2/magento-error.log'
          },
          'my-site.localhost' => {
            'vhost' => 'my-site.localhost',
            'conf' => '/etc/apache2/sites-enabled/my_site.conf:1',
            'port' => '80',
            'docroot' => '/srv/vhost_sample',
            'accesslogs' => [
              '/var/log/apache2/my_site-access.log combined'
            ],
            'errorlog' => '/var/log/apache2/my_site-error.log'
          },
          'wordpress.example.com' => {
            'vhost' => 'wordpress.example.com',
            'conf' => '/etc/apache2/sites-enabled/wordpress.conf:1',
            'port' => '80',
            'docroot' => '/srv/wordpress_sample',
            'accesslogs' => [
              '/var/log/apache2/wordpress-access.log combined'
            ],
            'errorlog' => '/var/log/apache2/wordpress-error.log'
          }
        }
      }
    else
      vhost_hash = {
        '*:80' => {
          'default' => {
            'vhost' => 'magento.example.com',
            'conf' => "#{apache_config_path}/sites-enabled/magento.conf:1",
            'docroot' => '/srv/magento',
            'accesslogs' => ["/var/log/#{apache_name}/magento-access.log combined"],
            'errorlog' => "/var/log/#{apache_name}/magento-error.log"
          },
          'magento.example.com' => {
            'vhost' => 'magento.example.com',
            'conf' => "#{apache_config_path}/sites-enabled/magento.conf:1",
            'port' => '80',
            'docroot' => '/srv/magento',
            'accesslogs' => ["/var/log/#{apache_name}/magento-access.log combined"],
            'errorlog' => "/var/log/#{apache_name}/magento-error.log"
          },
          'my-site.localhost' => {
            'vhost' => 'my-site.localhost',
            'conf' => "#{apache_config_path}/sites-enabled/my_site.conf:1",
            'port' => '80',
            'docroot' => '/srv/vhost_sample',
            'accesslogs' => ["/var/log/#{apache_name}/my_site-access.log combined"],
            'errorlog' => "/var/log/#{apache_name}/my_site-error.log"
          },
          'wordpress.example.com' => {
            'vhost' => 'wordpress.example.com',
            'conf' => "#{apache_config_path}/sites-enabled/wordpress.conf:1",
            'port'=>'80',
            'docroot' => '/srv/wordpress_sample',
            'accesslogs' => ["/var/log/#{apache_name}/wordpress-access.log combined"],
            'errorlog' => "/var/log/#{apache_name}/wordpress-error.log"
          }
        }
      }
    end

    expect(apache2['vhosts']).to eql(vhost_hash)
  end
end
