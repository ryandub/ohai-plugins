# Encoding: utf-8
require 'spec_helper'

pam = OHAI['etc']['pam']

describe 'Pam Configuration Plugin' do

  it 'should be a Mash' do
    expect(pam).to be_a(Mash)
  end

  it 'should have a value' do
    expect(pam.keys).not_to be_empty
  end

end
