# Encoding: utf-8
require 'spec_helper'

cronjobs = OHAI['cronjobs']['root'][0]

describe 'Cron Plugin' do

  it 'should be a Mash' do
    expect(cronjobs).to be_a(Mash)
  end

  it 'should report the minute' do
    expect(cronjobs['m']).to eql('0')
  end

  it 'should report the hour' do
    expect(cronjobs['h']).to eql('0')
  end

  it 'should report the day of the month' do
    expect(cronjobs['dom']).to eql('1')
  end

  it 'should report the month' do
    expect(cronjobs['mon']).to eql('3')
  end

  it 'should report the day of the week' do
    expect(cronjobs['dow']).to eql('0')
  end

  it 'should report the command' do
    expect(cronjobs['command']).to include('echo')
  end
end
