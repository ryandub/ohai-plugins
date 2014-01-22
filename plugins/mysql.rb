Ohai.plugin(:Mysql) do
  provides 'mysql'

  def mysql_status()
    so = shell_out("#{mysqladmin_bin()} status")
    mysqlstatus = so.stdout.strip
    return Hash[mysqlstatus.scan(/(\w+): (\w+)/).map { |(k, v)| [k.downcase.to_sym, v.to_i] }]
  end

  def max_sql_connections()
    command = <<-EOS
      #{mysql_bin()} -e 'show variables like "max_connections"' -B | tail -n 1 | awk '{print $2}'
    EOS

    so = shell_out(command)
    return so.stdout.to_i
  end

  def mysql_bin()
    unless @mysql_bin
      so = shell_out("which mysql")
      mysql_bin = so.stdout.strip
    end
    return mysql_bin unless mysql_bin.empty?
  end

  def mysqlserver_bin()
    unless @mysqlserver_bin
      so = shell_out("which mysqld")
      mysqlserver_bin = so.stdout.strip
    end
    return mysqlserver_bin unless mysqlserver_bin.empty?
  end

  def mysqladmin_bin()
    unless @mysqladmin_bin
      so = shell_out("which mysqladmin")
      mysqladmin_bin = so.stdout.strip
    end
    return mysqladmin_bin unless mysqladmin_bin.empty?
  end

  collect_data(:linux) do
    # Make sure we are on a MySQL Server and have the `mysql` command
    if mysql_bin() && mysqlserver_bin()
      mysql Mash.new
      mysql[:bin] = mysqlserver_bin()
      mysql[:status] = mysql_status()
      mysql[:configuration] = {
        :max_connections => max_sql_connections()
      }
    end
  end
end