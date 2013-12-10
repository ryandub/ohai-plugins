provides "mysql"

require_plugin 'linux::lsb'

def mysql_status()
  status = %x(#{mysqladmin_bin()} status).strip
  return Hash[status.scan(/(\w+): (\w+)/).map { |(k, v)| [k.downcase.to_sym, v.to_i] }]
end

def max_sql_connections()
  return `#{mysql_bin()} -e 'show variables like "max_connections"' -B | tail -n 1 | awk '{print $2}'`.to_i
end

def mysql_bin()
  return @mysql_bin ||= %x(which mysql).strip
end

def mysqladmin_bin()
  return @mysqladmin_bin ||= %x(which mysqladmin).strip
end

if mysql_bin()
  mysql Mash.new
  mysql[:bin] = mysql_bin()
  mysql[:status] = mysql_status()
  mysql[:configuration] = {
    max_connections: max_sql_connections()
  }
end