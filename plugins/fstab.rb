# Encoding: UTF-8
Ohai.plugin(:Fstab) do
  provides 'fstab'

  collect_data(:linux) do
    fstab Mash.new
    fstab_entries = Array.new
    so = shell_out('cat /etc/fstab')
    so.stdout.lines.each do |line|
      fstab_entries.push(line) unless line.start_with?('#')
    end
    fstab_return = Hash.new
    entry_hash = Hash.new
    fstab_entries.each do |entry|
      line = entry.split(' ')
      entry_hash[line[0]] = { 'mount point' => line[1],
                              'type' => line[2],
                              'options' => line[3].split("'"),
                              'dump' => line[4],
                              'pass' => line[5] }
    end
    fstab_return['fstab'] = entry_hash
    fstab.merge!(fstab_return) unless fstab_return.empty?
  end
end
