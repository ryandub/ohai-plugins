# Encoding: utf-8
# A plugin to discover IPTables rules configured on a server
Ohai.plugin(:Iptables) do
	provides 'iptables'


	collect_data(:linux) do
		iptables Mash.new # Creating a mash of present IPTables rules
		so = shell_out("sudo iptables -S")
		so.stdout.each_line.with_index do |line, i|
			iptables[i] = line.strip
		end
	end

end