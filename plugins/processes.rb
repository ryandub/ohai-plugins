Ohai.plugin(:Processes) do
  provides 'processes'

  collect_data(:linux) do
    processes Mash.new

    command = "ps -eo pid,euser,start_time,nice,%cpu,%mem,cmd"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)

    stdout.lines do |line|
      case line
      when /  PID EUSER    START  NI %CPU %MEM CMD/
        next
      else
        line = line.split("\s")
        info = line.shift(6)
        pid = info[0]
        cmd = line.join(" ")
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