require 'spec_helper'

installed_services = OHAI['installed_services']
platform_family = OHAI['platform_family']
platform_version = OHAI['platform_version'].to_f

describe 'InstalledServices Plugin' do

  it 'should be a Mash' do
      expect(installed_services).to be_a(Mash)
  end
  
  if platform_family == 'ubuntu'
    it 'should have a value for init' do
      expect(installed_services['init']).not_to be_empty
    end
  elsif platform_family == 'rhel' and platform_version < 6
    it 'should have a value for init' do
      expect(installed_services['init']).not_to be_empty
    end
  end

  it 'should have a value for initd' do
    expect(installed_services['initd']).not_to be_empty
  end

  if platform_family == 'rhel' and platform_version > 6
    it 'should have a value for system' do
      expect(installed_services['system']).not_to be_empty
    end
  end
end
