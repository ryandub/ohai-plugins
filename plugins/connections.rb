# A plugin to try to determine the remote servers this server
# uses (ex. mysql databases, etc...) by listing the addresses
# and ports that this server connects to.
#
# Data is returned is an hash with remote ip and a port list.
# Inbound connections are assumed based on LISTENing ports and
# are not included in the output.
#
require 'set'

Ohai.plugin(:Connections) do
  provides "connections"

  collect_data(:linux) do
    connections Mash.new
    exclude = Set.new

    # Get connections from netstat
    output = shell_out("netstat -naten")
    if output
      lines = output.stdout.split(/\n/).reject(&:empty?)[2..-1]
    end

    if lines
      for line in lines
        line_data = line.split()

        address = line_data[4].split(":")[0..-2].join(':')

        state = line_data[5]
        if state == "LISTEN"
          exclude.add(address)
        else
          # Add foreign (remote) ip/port
          port = line_data[4].split(":")[-1].to_i
          connections[address] = [] unless connections[address]
          connections[address] |= [port]
        end
      end
    end

    # Get connections from arp cache
    output = shell_out("arp -an")
    if output
      lines = output.stdout.split(/\n/).reject(&:empty?)
    end

    if lines
      for line in lines
        line_data = line.split()
        address = line_data[1][1..-2]
        if not exclude.include?(address)
          connections[address] = [] unless connections[address]
        end
      end
    end

  end
end