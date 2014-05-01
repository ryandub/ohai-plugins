# Encoding: utf-8
require 'spec_helper'

permissions = OHAI['permissions']

describe 'Permissions Plugin' do

  it 'should be a Mash' do
    expect(permissions).to be_a(Mash)
  end

  it '/etc/passwd should have 644 permissions' do
    expect(permissions['/etc/passwd']).to eql(644)
  end

end
