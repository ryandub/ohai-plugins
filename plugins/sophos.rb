# Encoding utf-8
Ohai.plugin(:Sophos) do
  provides 'sophos'

  def sophos_bin()
    if File.exist?('/opt/sophos-av/bin/savdstatus')
      return true
    end
  end

  def get_sophos_data()
    sophos Mash.new
    so = shell_out("/opt/sophos-av/bin/savdstatus --version")
    so.stdout.lines do |line|
      version = /Sophos Anti-Virus[[:space:]]+=[[:space:]]([[[:digit:]].]+)/.match(line)
        if version
          sophos['version'] = version[1]
          next
        end
      last_update = /Last update[[:space:]]+=[[:space:]](.*)/.match(line)
      if last_update
        sophos['update'] = Date.strptime(last_update[1], format='%a %d %b %Y %r %Z')
      end
    end

    return sophos
  end

  collect_data(:linux) do
    if sophos_bin()
      get_sophos_data
    end
  end

end
