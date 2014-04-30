# Encoding: utf-8
require 'spec_helper'

login = OHAI['etc']['login']

describe 'Login Configuration Plugin' do

  it 'should be a Mash' do
    expect(login).to be_a(Mash)
  end

  it 'should have a value' do
    expect(login.keys).not_to be_empty
  end

  it 'should have PASS_MAX_DAYS value of 99999' do
    expect(login['PASS_MAX_DAYS']).to eql('99999')
  end

  it 'should have PASS_MIN_DAYS value of 0' do
    expect(login['PASS_MIN_DAYS']).to eql('0')
  end

  it 'should have PASS_WARN_AGE value of 7' do
    expect(login['PASS_WARN_AGE']).to eql('7')
  end

end
