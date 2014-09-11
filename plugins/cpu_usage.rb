Ohai.plugin(:CPUUsage) do
  provides 'cpu/usage'
  depends 'cpu'

  collect_data(:linux) do
    cpu[:all] = Mash.new

    so = shell_out('mpstat -P ALL')
    so.stdout.lines do |line|
      case line
      when /[0-9]*\.[0-9]{2}$/
        info = line.split("\s")
        cpu_num = info[1]
        cpu[cpu_num][:usr] = info[2]
        cpu[cpu_num][:nice] = info[3]
        cpu[cpu_num][:sys] = info[4]
        cpu[cpu_num][:iowait] = info[5]
        cpu[cpu_num][:irg] = info[6]
        cpu[cpu_num][:soft] = info[7]
        cpu[cpu_num][:steal] = info[8]
        cpu[cpu_num][:guest] = info[9]
        cpu[cpu_num][:idle] = info[10]
      end
    end
  end
end
