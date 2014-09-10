Ohai.plugin(:Routes) do
  depends 'platform_family'
  provides 'routes'

  collect_data(:linux) do
    if platform_family.eql?('debian')
      lines_v4 = shell_out('netstat -nr4').stdout
      lines_v6 = shell_out('netstat -nr6').stdout
    elsif platform_family.eql?('rhel')
      lines_v4 = ('netstat -nr').stdout
      lines_v6 = ('netstat --inet6 -nr').stdout
    end

    routes Mash.new
    if lines_v4
      routes['inet'] = Array.new
      lines_v4.lines do |line|
        case line
        when /Kernel/
          next
        when /Destination/
          next
        else
          line_data = line.split
          routes['inet'].push(
            'destination' => line_data[0],
            'gateway' => line_data[1],
            'genmask' => line_data[2],
            'flags' => line_data[3],
            'mss' => line_data[4],
            'window' => line_data[5],
            'irtt' => line_data[6],
            'iface' => line_data[7]
          )
        end
      end
    end

    if lines_v6
      routes['inet6'] = Array.new
      lines_v6.lines do |line|
        case line
        when /Kernel/
          next
        when /Destination/
          next
        else
          line_data = line.split
          routes['inet6'].push(
            'destination' => line_data[0],
            'next_hop' => line_data[1],
            'flags' => line_data[2],
            'metric' => line_data[3],
            'ref' => line_data[4],
            'use' => line_data[5],
            'iface' => line_data[6]
          )
        end
      end
    end
  end
end
