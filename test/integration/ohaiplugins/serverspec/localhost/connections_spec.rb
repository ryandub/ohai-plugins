# Encoding: utf-8
require 'spec_helper'

conns = OHAI['connections']

describe 'Connections Plugin' do

  it 'should be an array' do
    expect(conns).to be_a(Mash)
  end

  it 'should have a value' do
    expect(conns.keys).not_to be_empty
  end

end
