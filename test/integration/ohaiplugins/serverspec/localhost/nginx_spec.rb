# Encoding: utf-8
require 'spec_helper'

cronjobs = OHAI['cronjobs']['root'][0]
nginx = OHAI['nginx_config']

describe 'Nginx Config' do

  it 'should be a Mash' do
    expect(nginx).to be_a(Mash)
  end

  it 'should report configure_arguments' do
    expect(nginx['configure_arguments']).to be_a(Array)
  end

  it 'should report ssl configure_argument' do
    expect(nginx['configure_arguments']).to include('--with-http_ssl_module')
  end

  it 'should report the prefix' do
    expect(nginx['prefix']).to eql('/usr/share/nginx')
  end

  it 'should report configuration path' do
    expect(nginx['conf_path']).to eql('/etc/nginx/nginx.conf')
  end

end
