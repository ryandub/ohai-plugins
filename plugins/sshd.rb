# Encoding: utf-8
Ohai.plugin(:Sshd) do
  provides 'sshd'

  collect_data(:linux) do
    sshd Mash.new
    so = shell_out('sshd -T')
    so.stdout.lines do |line|
      line = line.split(' ')
      sshd[line[0]] = line[1..-1].join(' ')
    end
  end
end
