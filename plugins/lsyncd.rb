Ohai.plugin(:Lsyncd) do
  provides 'lsyncd'

  def find_lsyncd_bin
    unless @lsyncd_bin
      so = shell_out("which lsyncd")
      lsyncd_bin = so.stdout.strip
    end
    return lsyncd_bin unless lsyncd_bin.empty?
  end

  def find_lsyncd_process(lsyncd_command)
    unless @lsyncd_process
      command = "ps -eo euser,ruser,suser,fuser,f,cmd|grep #{lsyncd_command}|grep -v grep"
      so = shell_out(command)
      lsyncd_process = so.stdout.strip
    end
    return lsyncd_process unless lsyncd_process.empty?
  end

  def find_lsyncd_config_file(lsyncd_process)
    unless @lsyncd_config_file
      config_file = lsyncd_process.split(" ")[6]
    end
    return config_file
  end

  def lsyncd_status_ok(lsyncd_process)
    unless @lsyncd_status_ok
      if lsyncd_process.nil?
        lsyncd_status_ok = false
      else
        lsyncd_status_ok = true
      end
    end
    return lsyncd_status_ok
  end

  collect_data(:linux) do
    if lsyncd_bin = find_lsyncd_bin()
      lsyncd Mash.new
      lsyncd[:bin] = lsyncd_bin
      process = find_lsyncd_process(lsyncd_bin)
      lsyncd[:status] = lsyncd_status_ok(process)
      lsyncd[:config_file] = find_lsyncd_config_file(process)
      lsyncd[:config_file] = process
    end
  end
end