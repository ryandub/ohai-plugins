require 'spec_helper'

ip_tables = OHAI['ip_tables']

describe 'Ip_tables Plugin' do

  it 'should be a Mash' do
    expect(ip_tables).to be_a(Mash)
  end

  it 'should contain rules' do
    expect(ip_tables[0]).not_to be_empty
  end

end
