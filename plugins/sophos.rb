# Encoding utf-8
Ohai.plugin(:Sophos) do
  require 'date'
  provides 'sophos'

  def sophos_bin
    return true if File.exist?('/opt/sophos-av/bin/savdstatus')
  end

  def get_sophos_version
    version_file = '/opt/sophos-av/engine/version'

    if File.exist?(version_file)
      version_fd = File.new(version_file, 'r')
      version = version_fd.gets.chomp
    end

    return version
  end

  def get_sophos_update
    last_update = {}
    update_file = '/opt/sophos-av/etc/update.last_update'
    if File.exist?(update_file)
      update_fd = File.new(update_file)
      update_time = update_fd.gets.chomp
      date = Time.at(update_time.to_i).strftime(
        '%H:%M:%S %Y %m %d %Z').split(' ')

      last_update = {
        'timezone' => date[4],
        'time' => date[0],
        'date' => {
          'year' => date[1],
          'month' => date[2],
          'day' => date[3]
        }
      }
    end
    return last_update
  end

  def check_active(filename)
    if File.exist?(filename)
      status_file = File.new(filename, 'r')
      line = status_file.gets
      return 'active' if (line.chomp == 'active')
    end
    return 'inactive'
  end

  def get_sophos_status
    status = {
      'onaccess' => check_active('/opt/sophos-av/var/run/onaccess.status'),
      'savd' => check_active('/opt/sophos-av/var/run/savd.status'),
      'av' => check_active('/opt/sophos-av/var/run/av.status')
    }
    return status
  end

  collect_data(:linux) do

    if sophos_bin
      sophos Mash.new
      sophos['status'] = get_sophos_status
      sophos['last_update'] = get_sophos_update
      sophos['version'] = get_sophos_version
    end
  end

end
