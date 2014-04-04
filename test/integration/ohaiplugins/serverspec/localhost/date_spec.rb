# Encoding: utf-8
require 'spec_helper'
require 'time'

date = OHAI['datetimeinfo']
now = Time.now.strftime('%Z %a %B %d %Y').split(' ')

describe 'Date Plugin' do

  it 'should report the timezone' do
    expect(date['timezone']).to eql(now[0])
  end

  it 'should report the day of the week' do
    expect(date['date'][0]).to eql(now[1])
  end

  it 'should report the day of the month' do
    expect(date['date'][2]).to eql(now[3])
  end

  it 'should report the name of the month' do
    expect(date['date'][1]).to eql(now[2])
  end

  # TODO(Gus): Date plugin needs to report month as integer.
  # it 'should report the month' do
  #   expect(date['date'][?]).to eql(now[?])
  # end

  it 'should report the year' do
    expect(date['date'][3]).to eql(now[4])
  end

end
