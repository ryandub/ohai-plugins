# Encoding: utf-8
require 'spec_helper'

processes = OHAI['processes']

describe 'Processes Plugin' do

  it 'should be a mash' do
    expect(processes).to be_a(Mash)
  end

  it 'should report process user' do
    expect(processes['1']).to include('user')
  end

  it 'should report process start time' do
    expect(processes['1']).to include('start_time')
  end

  it 'should report process nice' do
    expect(processes['1']).to include('nice')
  end

  it 'should report process cpu' do
    expect(processes['1']).to include('cpu')
  end

  it 'should report process memory' do
    expect(processes['1']).to include('mem')
  end

end
