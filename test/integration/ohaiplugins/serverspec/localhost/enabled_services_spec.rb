require 'spec_helper'

enabled_services = OHAI['enabled_services']
platform_family = OHAI['platform_family']
platform_version = OHAI['platform_version'].to_f

describe 'EnabledServices Plugin' do

  it 'should be a Mash' do
      expect(enabled_services).to be_a(Mash)
  end

  if platform_family == 'debian'
    it 'should have a value' do
      expect(enabled_services['upstart']).not_to be_empty
    end
  end
  if platform_family == 'rhel'
    if platform_version < 7
      it 'should have a value' do
        expect(enabled_services['systemv']).not_to be_empty
      end
    else
      it 'should have a value' do
        expect(enabled_services['systemd']).not_to be_empty
      end
    end
  end
end
