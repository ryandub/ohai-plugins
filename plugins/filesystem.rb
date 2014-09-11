Ohai.plugin(:FilesystemInodes) do
  provides 'filesystem/inodes'
  depends 'filesystem'

  collect_data(:linux) do
    # Grab filesystem inode data from df
    so = shell_out('df -i')
    so.stdout.lines do |line|
      case line
      when /^Filesystem\s+Inodes/
        next
      when /^(.+?)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+\%)\s+(.+)$/
        fs = $1
        filesystem[fs] ||= Mash.new
        filesystem[fs][:total_inodes] = $2
        filesystem[fs][:inodes_used] = $3
        filesystem[fs][:inodes_available] = $4
        filesystem[fs][:inodes_percent_used] = $5
        filesystem[fs][:mount] = $6
      end
    end
  end
end
