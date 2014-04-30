# Encoding: utf-8
# Report /etc/login.defs configuration

Ohai.plugin(:Login) do
  depends 'etc'
  provides 'etc/login'

  def parse_login_defs
    defs = {}
    f = File.open('/etc/login.defs')
    f.each_line do |line|
      line = strip_comments(line)
      unless line.strip.empty?
        line = line.split(' ')
        defs[line[0]] = line[1..-1].join(' ')
      end
    end
    f.close
    defs
  end

  def strip_comments(text)
    re = Regexp.union(['#'])
    if index = (text =~ re)
      return text[0, index].rstrip
    else
      return text
    end
  end

  collect_data(:linux) do
    defs = parse_login_defs
    etc['login'] = defs unless defs.empty?
  end
end
