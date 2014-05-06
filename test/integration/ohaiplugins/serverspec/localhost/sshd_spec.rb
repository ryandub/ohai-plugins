# Encoding: utf-8
require 'spec_helper'

sshd = OHAI['sshd']
platform_family = OHAI['platform_family']
platform_version = OHAI['platform_version'].to_f
if OHAI['passwd'].key?('vagrant')
  vagrant = true
else
  vagrant = false
end

if platform_family == 'debian' && platform_version >= 14.04 && vagrant
  permitrootlogin = 'without-password'
else
  permitrootlogin = 'yes'
end

unless platform_family == 'rhel' && platform_version < 6

  describe 'sshd Plugin' do

    it 'should be a Mash' do
      expect(sshd).to be_a(Mash)
    end

    it 'should have a value' do
      expect(sshd.keys).not_to be_empty
    end

    it 'should have port value of 22' do
      expect(sshd['port']).to eql('22')
    end

    it 'should use ssh protocol 2' do
      expect(sshd['protocol']).to eql('2')
    end

    it 'should have permitrootlogin value of "yes"' do
      expect(sshd['permitrootlogin']).to eql(permitrootlogin)
    end

    it 'should have x11forwarding value of "yes"' do
      expect(sshd['x11forwarding']).to eql('yes')
    end

    it 'should have ignorerhosts value of "yes"' do
      expect(sshd['ignorerhosts']).to eql('yes')
    end

  end

end
