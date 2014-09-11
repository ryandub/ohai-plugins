Ohai.plugin(:Mysql) do
  provides 'mysql'
  depends 'platform', 'platform_family'

  def mysql_status
    so = shell_out("#{mysqladmin_bin} status")
    mysqlstatus = so.stdout.strip
    # rubocop:disable Metrics/LineLength
    return Hash[mysqlstatus.scan(/(\w+): (\w+)/).map { |(k, v)| [k.downcase.to_sym, v.to_i] }]
    # rubocop:enable Metrics/LineLength
  end

  def mysql_bin
    unless @mysql_bin
      so = shell_out("/bin/bash -c 'command -v mysql'")
      mysql_bin = so.stdout.strip
    end
    return mysql_bin unless mysql_bin.empty?
  end

  def mysqlserver_bin
    unless @mysqlserver_bin
      if platform_family == 'debian'
        so = shell_out("/bin/bash -c 'command -v mysqld'")
      elsif platform_family == 'rhel'
        so = shell_out("/bin/bash -c 'command -v mysqld_safe'")
      end
      mysqlserver_bin = so.stdout.strip
    end
    return mysqlserver_bin unless mysqlserver_bin.empty?
  end

  def mysqladmin_bin
    unless @mysqladmin_bin
      so = shell_out("/bin/bash -c 'command -v mysqladmin'")
      mysqladmin_bin = so.stdout.strip
    end
    return mysqladmin_bin unless mysqladmin_bin.empty?
  end

  def mysql_config(input)
    command = "#{mysql_bin} -Bse 'show global #{input}'"

    output = {}
    so = shell_out(command)
    so.stdout.lines do |line|
      line = line.split("\t")
      output[line[0].downcase] = line[1].rstrip
    end
    return output
  end

  collect_data(:linux) do
    # Make sure we are on a MySQL Server and have the `mysql` command
    if mysql_bin && mysqlserver_bin
      mysql Mash.new
      mysql[:bin] = mysqlserver_bin
      mysql[:status] = mysql_status
      mysql[:mysql_variables] = mysql_config('variables')
      mysql[:mysql_status] = mysql_config('status')
    end
  end
end
