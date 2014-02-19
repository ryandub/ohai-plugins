Ohai.plugin(:Sysctl) do
  provides 'sysctl'

  collect_data(:linux) do
    sysctl Mash.new

    # platform detection should go here
    # right now only centos/linux tested
    cmd = "sysctl -A"

    status, stdout, stderr = run_command(:command => cmd)
    return "" if stdout.nil? || stdout.empty?
    stdout.each_line do |line|
      k,v = line.split(/=/).map {|i| i.strip!}
      sysctl[k] = v
    end
  end
end