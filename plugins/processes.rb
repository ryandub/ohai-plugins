# Encoding: utf-8
Ohai.plugin(:Processes) do
  provides 'processes'

  collect_data(:linux) do
    processes Mash.new

    so = shell_out('ps -eo pid,euser,start_time,nice,%cpu,%mem,cmd')

    so.stdout.lines do |line|
      case line
      when /  PID EUSER    START  NI %CPU %MEM CMD/
        next
      else
        line = line.split("\s")
        info = line.shift(6)
        pid = info[0]
        cmd = line.join(' ')
        processes[pid] = Mash.new
        processes[pid][:user] = info[1]
        processes[pid][:start_time] = info[2]
        processes[pid][:nice] = info[3]
        processes[pid][:cpu] = info[4]
        processes[pid][:mem] = info[5]
        processes[pid][:command] = cmd
      end
    end
  end
end
