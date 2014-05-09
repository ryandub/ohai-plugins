require 'spec_helper'

fail2ban = OHAI['fail2ban']

describe 'fail2ban Plugin' do
  it 'should be an Mash' do
    expect(fail2ban).to be_a(Mash)
  end

  it 'should find lines in the fail2ban log' do
    line='2014-04-30 10:46:24,006 fail2ban.actions: WARNING [ssh] Ban 1.1.1.1'
    expect(fail2ban['activity'][0]).to eql(line)
  end

  it 'should find one ban on 1.1.1.1' do
    expect(fail2ban['banned']['1.1.1.1']['ssh']['count']).to eql(1)
  end

  it 'should find 2.2.2.2 banned' do
    expect(fail2ban['banned']['2.2.2.2']['ssh']['status']).to eql('Ban')
  end

  it 'should find active jails' do
    expect(fail2ban['jails'][0]).to include('ssh')
  end
end
