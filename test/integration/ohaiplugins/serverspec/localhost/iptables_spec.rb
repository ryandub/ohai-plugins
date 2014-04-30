require 'spec_helper'

iptables = OHAI['iptables']

describe 'Iptables Plugin' do
	
  it 'should be an Mash' do
    expect(iptables).to be_a(Mash)
  end

  it 'should contain rules' do
    expect(iptables[0]).not_to be_empty
  end

end

