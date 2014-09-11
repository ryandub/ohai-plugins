# Encoding: utf-8
# Report /etc/login.defs configuration

Ohai.plugin(:Login) do
  depends 'etc'
  provides 'etc/login.defs'

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
    # rubocop:disable Lint/AssignmentInCondition
    if index = (text =~ re)
      # rubocop:enable Lint/AssignmentInCondition
      return text[0, index].rstrip
    else
      return text
    end
  end

  collect_data(:linux) do
    defs = parse_login_defs
    unless defs.empty?
      etc Mash.new unless etc
      etc['login.defs'] = defs unless defs.empty?
    end
  end
end
