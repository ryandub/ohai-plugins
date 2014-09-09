# Encoding: utf-8

Ohai.plugin(:Sysctl) do
  provides 'sysctl'

  collect_data(:linux) do
    sysctl Mash.new

    # platform detection should go here
    # right now only centos/linux tested
    cmd = 'sysctl -A'

    so = shell_out(cmd)
    so.stdout.lines do |line|
      k, v = line.split(/=/).map(&:strip!)
      sysctl[k] = v
    end
  end
end
