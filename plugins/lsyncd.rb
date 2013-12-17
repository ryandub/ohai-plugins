provides "lsyncd"

def find_lsyncd_bin
  unless @lsyncd_bin
    command = "which lsyncd"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)
    lsyncd_bin = stdout.strip
  end
  return lsyncd_bin unless lsyncd_bin.empty?
end

def lsyncd_status_ok(lsyncd_command)
  unless @lsyncd_status_ok
    command = "ps -eo euser,ruser,suser,fuser,f,cmd|grep #{lsyncd_command}|grep -v grep"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)
    if status == 0
      lsyncd_status_ok = true
    else
      lsyncd_status_ok = false
    end
  end
end

if lsyncd_bin = find_lsyncd_bin()
  lsyncd Mash.new
  lsyncd[:bin] = lsyncd_bin
  lsyncd[:status_ok] = lsyncd_status_ok(lsyncd_bin)
end