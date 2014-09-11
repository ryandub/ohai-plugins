# Encoding: utf-8
require 'spec_helper'

platform_family = OHAI['platform_family']

if platform_family == 'rhel'
  rhcssvcs = OHAI['rhcs_services']
  rhcsnodes = OHAI['rhcs_nodes']

  describe 'RHCS Plugin' do

    it 'should be an array' do
      expect(rhcssvcs).to be_a(Mash)
    end

    it 'should have a value' do
      expect(rhcssvcs.keys).not_to be_empty
    end

    it 'should be an array' do
      expect(rhcsnodes).to be_a(Mash)
    end

    it 'should have a value' do
      expect(rhcsnodes.keys).not_to be_empty
    end

  end
end
