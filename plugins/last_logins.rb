Ohai.plugin(:Logins) do
  provides 'logins'

  collect_data(:linux) do

    logins Mash.new

    logged_in = []
    previous_logins = []
    so = shell_out('last')
    so.stdout.lines do |line|
      case line
      when /still logged in/
        line_data = line.split(' ')
        logged_in.push(
          'user' => line_data[0],
          'host' => line_data[2],
          'login_time' => "#{line_data[3]} #{line_data[4]} #{line_data[5]}"\
                          ":#{line_data[6]}"
        )
      else
        unless line.include?('system boot')
          line_data = line.split(' ')
          previous_logins.push(
            'user' => line_data[0],
            'host' => line_data[2],
            'login_time' => "#{line_data[3]} #{line_data[4]} #{line_data[5]}"\
                            ":#{line_data[6]}"
          )
        end
      end
    end

    logins[:logged_in] = logged_in
    logins[:previous_logins] = previous_logins
  end
end
