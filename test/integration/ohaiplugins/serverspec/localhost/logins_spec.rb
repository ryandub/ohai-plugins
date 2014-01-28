require 'spec_helper'

logins = OHAI['logins']

describe "LastLogins Plugin" do

  it "should have currently logged in users" do
    expect(logins['logged_in']).not_to be_empty
  end

  it "should have previous logged in users" do
    expect(logins['previous_logins']).not_to be_empty
  end

end