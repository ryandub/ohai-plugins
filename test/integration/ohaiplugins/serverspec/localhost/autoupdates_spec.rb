# Encoding: utf-8
require 'spec_helper'

autoupdates = OHAI['autoupdates']
platform_family = OHAI['platform_family']

case platform_family
when 'rhel'
  upgrade_app = 'yum-cron'
when 'debian'
  upgrade_app = 'unattended-upgrades'
end

describe 'AutoUpdates Plugin' do
  it 'should report updates enabled' do
    expect(autoupdates[upgrade_app]).to eql('enabled')
  end
end
