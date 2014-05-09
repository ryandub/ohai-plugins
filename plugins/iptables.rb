# Encoding: utf-8
# A plugin to discover IPtables rules configured on a server
Ohai.plugin(:Iptables) do
  provides 'ip_tables'

  def iptables_rules
    iptables = {}
    so = shell_out('iptables -S')
    so.stdout.each_line.with_index do |line, i|
      case line
      when /^-P/
        fields = line.strip.split(' ')
        iptables[i] = {
          'type' => 'policy',
          'chain' => fields[1],
          'policy' => fields[2]
        }
      when /^-A/
        dict = {}
        clobbered_fields = line.split('-')
        fields = clobbered_fields.map { |field| field.split(' ') }
        fields.each do |field|
          key = field[0] == 'A' ? 'chain' : field[0].to_s
          dict[key] = field[1]
        end
        dict.delete('')
        dict['type'] = 'rule'
        iptables[i] = dict
      end
    end
    iptables
  end

  collect_data(:linux) do
    rules = iptables_rules
    unless rules.empty?
      ip_tables Mash.new
      ip_tables.merge!(rules)
    end
  end
end
