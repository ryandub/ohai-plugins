# Encoding: utf-8
require 'spec_helper'

sophos = OHAI['sophos']

describe 'Sophos Plugin' do

  it 'should be a Mash' do
    expect(sophos).to be_a(Mash)
  end

  it 'be able to read statuses' do
    expect(sophos['status']).to be_a(Hash)
  end

  it 'check status of AV, Scanning & Savd' do
    for item in [ 'av', 'savd', 'onaccess' ]
      expect(sophos['status']).to include(item)
    end
  end

  it 'check time of last update' do
    expect(sophos['last_update']).to be_a(Hash)
  end

  it 'check time of last update returned' do
    for item in [ 'timezone', 'time', 'date' ]
      expect(sophos['last_update']).to include(item)
    end
  end

  it 'should have a version' do
    expect(sophos).to include('version')
  end

end
