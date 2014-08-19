# Encoding utf-8
Ohai.plugin(:Sophos) do
  require 'date'
  provides 'sophos'

  def sophos_bin()
    if File.exist?('/opt/sophos-av/bin/savdstatus')
      return true
    end
  end

  def get_sophos_version()
    version_file = '/opt/sophos-av/engine/version'

    if File.exists?(version_file)
      version_fd = File.new(version_file, 'r')
      version = version_fd.gets().chomp()
    end

    return version
  end

  def get_sophos_update(sophos)
    update_file = '/opt/sophos-av/etc/update.last_update'

    if File.exists?(update_file)

      update_fd = File.new(update_file)
      update_time = update_fd.gets().chomp()
      date = Time.at(update_time.to_i).strftime('%H:%M:%S %Y %m %d %Z').split(' ')

      sophos[:last_update] = {
        :timezone => date[4],
        :time => date[0],
        :date => {
          :year => date[1],
          :month => date[2],
          :day => date[3]
        }
      }

    end
  end



  def check_active(filename)
    
    if File.exists?(filename)

      status_file = File.new(filename, 'r')
      line = status_file.gets
      if (line.chomp() == 'active')
        return 'active'

      end
    end

    return 'inactive'
  end

  def get_sophos_status(sophos)
    
    sophos[:status] = {
      :onaccess => check_active("/opt/sophos-av/var/run/onaccess.status"),
      :savd => check_active("/opt/sophos-av/var/run/savd.status"),
      :av => check_active("/opt/sophos-av/var/run/av.status")
    }

  end

  collect_data(:linux) do

    if sophos_bin()

      sophos Mash.new
      get_sophos_status(sophos)
      get_sophos_update(sophos)
      sophos[:version] = get_sophos_version()

    end
  end

end
