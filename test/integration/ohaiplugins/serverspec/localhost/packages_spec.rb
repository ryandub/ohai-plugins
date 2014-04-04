# Encoding: utf-8
require 'spec_helper'

packages = OHAI['packages']

describe 'Packages Plugin' do

  it 'should be a Mash' do
    expect(packages).to be_a(Mash)
  end

  it 'should have python installed' do
    expect(packages['python']).to be_a(Hash)
  end

  it 'should report versions' do
    expect(packages['python']).to include('version')
  end

end
