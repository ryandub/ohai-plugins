# A plugin to try to determine the remote servers this server
# uses (ex. mysql databases, etc...) by listing the addresses
# and ports that this server connects to.
#
# Data is returned is an hash with remote ip and a port list.
# Inbound connections are assumed based on LISTENing ports and
# are not included in the output.
#
require 'resolv'
require 'set'
require 'socket'

Ohai.plugin(:Connections) do
  provides 'connections'

  collect_data(:linux) do
    connections Mash.new           # This contains the output we will return
    remotes = Set.new              # Addresses of remote hosts we have found
    ipv4_wildcard_ports = Set.new  # Ports that are listening on all addresses
    ipv6_wildcard_ports = Set.new  # Ports that are listening on all addresses
    listeners = Set.new            # address/port combos that are listening
    active = Hash.new              # All active connections

    # Get local IP addresses
    addresses = Socket.ip_address_list
    local_ipv4_addresses = addresses.reject(&:ipv4?).map(&:ip_address)
    local_ipv6_addresses = addresses.reject(&:ipv6?).map(&:ip_address)
    Ohai::Log.debug("Local IPv4 addresses: #{local_ipv4_addresses}")
    Ohai::Log.debug("Local IPv6 addresses: #{local_ipv6_addresses}")

    # Get connections from netstat
    output = shell_out('netstat -naten')
    if output
      lines = output.stdout.split(/\n/).reject(&:empty?)[2..-1]

      if lines
        lines.each do |line|
          line_parts = line.split

          local_parts = line_parts[3].split(':')
          local_address = local_parts[0..-2].join(':')
          local_port = local_parts[-1].to_i

          foreign_parts = line_parts[4].split(':')
          foreign_address = foreign_parts[0..-2].join(':')
          foreign_port = foreign_parts[-1].to_i

          state = line_parts[5]

          # rubocop:disable DoubleNegation, LineLength
          if state == 'LISTEN'
            if local_address == '0.0.0.0'
              Ohai::Log.debug("IPv4 wildcard listener on port #{local_port}")
              ipv4_wildcard_ports.add(local_port)
            elsif local_address == '::'
              Ohai::Log.debug("IPv6 wildcard listener on port #{local_port}")
              ipv6_wildcard_ports.add(local_port)
            else
              Ohai::Log.debug("Listener on port #{local_port} bound to \
                              #{local_address}")
              listeners.add(local_parts.join(':'))
            end
          elsif !!(local_address =~ Resolv::IPv4::Regex) && ipv4_wildcard_ports.include?(local_port)
            remotes.add(foreign_address)
            Ohai::Log.debug("Skipping #{local_address}:#{local_port} because"\
                            ' it looks like an inbound connection to wildcard'\
                            ' listener')
          elsif !!(local_address =~ Resolv::IPv6::Regex) && ipv6_wildcard_ports.include?(local_port)
            remotes.add(foreign_address)
            Ohai::Log.debug("Skipping #{local_address}:#{local_port} because"\
                            ' it looks like an inbound connection to wildcard'\
                            ' listener')
          else
            Ohai::Log.debug('Possible remote connection to'\
                            " #{foreign_address}:#{foreign_port} detected")
            remotes.add(foreign_address)
            # Add foreign (remote) ip/port
            active[foreign_address] ||= []
            active[foreign_address] |= [foreign_port]
          end
        end
        # rubocop:enable DoubleNegation, LineLength
      end
    end

    # Get connections from arp cache
    output = shell_out('arp -an')
    lines = output.stdout.split(/\n/).reject(&:empty?) if output

    if lines
      lines.each do |line|
        line_parts = line.split
        address = line_parts[1][1..-2]
        unless remotes.include? address
          Ohai::Log.debug("Found #{address} in arp cache")
          active[address] ||= []
        end
      end
    end

    # Determine outbound connections and write them out
    active.keys.each do |address|
      ports = active[address]
      if ports == []
        Ohai::Log.debug("Adding #{address} as a remote without ports")
        connections[address] ||= []
      else
        # rubocop:disable DoubleNegation, LineLength
        ports.each do |port|
          if !!(address =~ Resolv::IPv4::Regex) && ipv4_wildcard_ports.include?(port)
            Ohai::Log.debug("Skipping #{address}:#{port} because it looks"\
                            ' like an inbound connection to wildcard listener')
          elsif !!(address =~ Resolv::IPv6::Regex) && ipv6_wildcard_ports.include?(port)
            Ohai::Log.debug("Skipping #{address}:#{port} because it looks"\
                            ' like an inbound connection to wildcard listener')
          elsif !!(address =~ Resolv::IPv4::Regex) && local_ipv4_addresses.include?(address)
            Ohai::Log.debug("Skipping #{address}:#{port} because it looks"\
                            ' like a local connection to a local address')
          elsif !!(address =~ Resolv::IPv6::Regex) && ipv6_wildcard_ports.include?(port)
            Ohai::Log.debug("Skipping #{address}:#{port} because it looks like"\
                            ' a local connection to a local address')
          elsif listeners.include?("#{address}:#{port}")
            Ohai::Log.debug("Skipping #{address}:#{port} because it looks like"\
                            ' an inbound connection to listener')
          else
            Ohai::Log.debug("Adding #{address} as a remote to #{port}")
            connections[address] ||= []
            connections[address] |= [port]
          end
        end
        # rubocop:enable DoubleNegation, LineLength
      end
    end

  end
end
