require 'spec_helper'

fail2ban = OHAI['fail2ban']

describe 'fail2ban Plugin' do
  it 'should find lines in the fail2ban log' do
    expect(fail2ban['activity'][0]).to eql('2014-04-30 10:46:24,006 fail2ban.actions: WARNING [ssh] Ban 1.1.1.1')
  end

  it 'should find active jails' do
    expect(fail2ban['jails'][0]).to include('ssh')
  end
end
