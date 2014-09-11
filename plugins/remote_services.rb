Ohai.plugin(:RemoteServices) do
  provides 'remote_services'

  collect_data(:linux) do
    output = shell_out('netstat -tlpen')
    lines = output.stdout.split(/\n/).reject(&:empty?)[2..-1] if output

    remote_services Array.new
    if lines
      lines.each do |line|
        line_data = line.split
        remote_services.push(protocol: line_data[0],
                             ip: line_data[3].split(':')[0..-2].join(':'),
                             port: line_data[3].split(':')[-1],
                             pid: line_data[-1].split('/')[0],
                             process: line_data[-1].split('/')[1],
                             path: line_data[-1])
      end
    end
  end
end
