# Encoding: utf-8
require 'spec_helper'
require 'time'

date = OHAI['datetimeinfo']
now = Time.now.strftime('%H:%M:%S %Y %m %d %Z').split(' ')

describe 'Date Plugin' do

  it 'should report the timezone' do
    expect(date['timezone']).to eql(now[4])
  end

  it 'should report the day of the month' do
    expect(date['date']['day']).to eql(now[3])
  end

  it 'should report the month' do
    expect(date['date']['month']).to eql(now[2])
  end

  it 'should report the year' do
    expect(date['date']['year']).to eql(now[1])
  end

  it 'should report the time' do
    expect(date['time']).to be_a(String)
  end

end
