Ohai.plugin(:Crontab) do
provides "cronjobs"

collect_data(:linux) do
  cronjobs Array.new
  out = `crontab -l`
    out.split("\n").each do |line|
      # check if line is a comment
      if !line.match(/^\s*#/)
        # extract values
        line.scan(/\s*([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+(.*)/) {
          |m,h,dom,mon,dow,cmd|
          cronjobs << {
            "m" => m,
            "h" => h,
            "dom" => dom,
            "mon" => mon,
            "dow" => dow,
            "command" => cmd
          }
        }
      end
    end
  end
end