# Encoding: utf-8
# Report passwd statuses

Ohai.plugin(:Passwd) do
  provides 'passwd'

  def get_passwd_status
    passwd = {}
    so = shell_out('passwd -S -a')
    so.stdout.lines do |line|
      line = line.split(' ')
      passwd[line[0]] = {
        'status' => line[1],
        'last_changed' => line[2],
        'minimum_age' => line[3],
        'maximum_age' => line[4],
        'warning_period' => line[5],
        'inactivity_period' => line[6]
      }
    end
    passwd
  end

  collect_data(:linux) do
    status = get_passwd_status
    unless status.empty?
      passwd Mash.new
      passwd.merge!(status)
    end
  end

end
