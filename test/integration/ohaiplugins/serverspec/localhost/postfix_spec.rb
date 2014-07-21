require 'spec_helper'

postfix = OHAI['postfix']
processes = OHAI['processes']
postfix_version = OHAI['packages']['postfix']['version']
platform_family = OHAI['platform_family']
platform_version = OHAI['platform_version']
fqdn = OHAI['fqdn']
domain = OHAI['domain']

# Find the Postfix process info from the processes plugin.
postfix_process = {}
processes.each do |pid, data|
    if data['command'] =~ /postfix\/master/
        postfix_process['pid'] = pid
        postfix_process['command'] = data['command']
    end
end

protocols_in_use = 'all'
origins = [
  '/etc/mailname',
  '$myhostname',
]

case platform_family
when 'debian'
  if[10, 6].include?(platform_version.to_i)
    protocols_in_use = 'ipv4'
  end

  listening_address = 'all'
  destinations = [
    fqdn,
    "localhost.#{domain}",
    'localhost'
  ]
  networks = "127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
  configfiles = [
    "/etc/postfix/main.cf",
    "/etc/postfix/master.cf",
    "/etc/postfix/post-install",
    "/etc/postfix/sasl",
    "/etc/postfix/dynamicmaps.cf",
    "/etc/postfix/postfix-script",
    "/etc/postfix/postfix-files"
  ]
when 'rhel'
  listening_address = 'localhost'
  destinations = [
    '$myhostname',
    'localhost.$mydomain',
    'localhost'
  ]
  networks = '127.0.0.0/8 [::1]/128'
  configfiles = [
    "/etc/postfix/header_checks",
    "/etc/postfix/relocated",
    "/etc/postfix/access",
    "/etc/postfix/virtual",
    "/etc/postfix/generic",
    "/etc/postfix/master.cf",
    "/etc/postfix/transport",
    "/etc/postfix/canonical",
    "/etc/postfix/main.cf"
  ]
end

describe "Postfix Plugin" do

    it 'should have postfix binary' do
        expect(postfix['postfix_binary']).to eql('/usr/sbin/postfix')
    end

    it 'should have postfix pid' do
        expect(postfix['process']['Master Process PID']).to eql(postfix_process['pid'])
    end

    it 'should have postfix command' do
       expect(postfix['process']['Master Process']).to eql(postfix_process['command']) 
    end

    it 'should have a postfix package version' do
        expect(postfix['postfix_package']['version']).to eql(postfix_version)
    end

    it 'should have a hostname configured' do
        expect(postfix['current_configuration']['Postfix Hostname']).to eql(fqdn)
    end

    it 'should have a domain name configured' do
       expect(postfix['current_configuration']['Postfix Domain Name']).to eql(domain)
    end

    it 'should report IP protocols' do
        expect(postfix['current_configuration']['IP protocols in use']).to eql(protocols_in_use)
    end

    it 'should report listening address' do
       expect(postfix['current_configuration']['Postfix Listening On Addresses']).to eql(listening_address)
    end

    it 'should report final destinations' do
       expect(postfix['current_configuration']['Postfix Final Destinations']).to include(*destinations)
    end

    it 'should report trusted client networks' do
       expect(postfix['current_configuration']['Postfix Trusted Client Networks']).to eql(networks)
    end

    it 'should report origin address' do
       expect(origins).to include(postfix['current_configuration']['Postfix Origin Address'])
    end

    it 'should report aliases database' do
       expect(postfix['current_configuration']['Postfix Aliases Database']).to eql('hash:/etc/aliases')
    end

    it 'should report configuration directory' do
       expect(postfix['current_configuration']['Postfix Configuration Directory']).to eql('/etc/postfix')
    end

    it 'should report configuration files' do
       expect(postfix['current_configuration']['Postfix Configuration Files']).to include(*configfiles)
   end

end
