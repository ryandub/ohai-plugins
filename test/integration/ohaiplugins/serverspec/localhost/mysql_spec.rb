require 'spec_helper'

mysql = OHAI['mysql']
platform_family = OHAI['platform_family']

describe "MySQL Plugin" do

  if platform_family == 'debian'
    mysqld_bin = '/usr/sbin/mysqld'
  elsif platform_family == 'rhel'
    mysqld_bin = '/usr/bin/mysqld_safe'
  end

  it 'should have the binary in the right location' do
    expect(mysql['bin']).to eql(mysqld_bin)
  end

  it "should report uptime" do
  	expect(mysql['status']['uptime'].to_i).to be > 1
  end

  it "should report threads" do
  	expect(mysql['status']['threads'].to_i).to be >= 1
  end

  it "should report questions" do
  	expect(mysql['status']['questions'].to_i).to be >= 1
  end

  it "should report queries" do
  	expect(mysql['status']['queries'].to_i).to be >= 0
  end

  it "should report opens" do
  	expect(mysql['status']['opens'].to_i).to be >= 1
  end

  it "should report tables" do
  	expect(mysql['status']['tables'].to_i).to be >= 0
  end

  it "should report avg" do
  	expect(mysql['status']['avg'].to_i).to be >= 0
  end

  it "should report max_connections" do
  	expect(mysql['mysql_variables']['max_connections'].to_i).to be >= 1
  end

end