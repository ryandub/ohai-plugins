# Encoding: utf-8
require 'spec_helper'

vulnerabilities = OHAI['vulnerabilities']

describe 'Vulnerabilities Plugin' do

  it 'should be an array' do
    expect(vulnerabilities).to be_a(Mash)
  end

  it 'should have a value' do
    expect(vulnerabilities.keys).not_to be_empty
  end
end
