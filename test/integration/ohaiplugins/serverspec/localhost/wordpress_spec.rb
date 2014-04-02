require 'spec_helper'

wordpress = OHAI['webapps']['wordpress']

describe "Wordpress Plugin" do
  it 'should be a hash' do
    expect(wordpress['wordpress.example.com']).to be_a(Hash)
  end

  it 'should report vhost' do
    expect(wordpress.keys.join).to eql('wordpress.example.com')
  end

  it "should report path" do
    expect(wordpress['wordpress.example.com']['path']).to eql('/srv/wordpress_sample/wp-config.php')
  end

  it "should report version" do
    expect(wordpress['wordpress.example.com']['version']).to be_a(String) 
  end

  it "should report plugins" do
    expect(wordpress['wordpress.example.com']['plugins']).to be_a(Hash)
  end

  it "should report Akismet plugin" do
    expect(wordpress['wordpress.example.com']['plugins'].keys.join).to eql('Akismet')
  end

  it "should report Akismet version" do
    expect(wordpress['wordpress.example.com']['plugins']['Akismet']['version']).to be_a(String)
  end
end

