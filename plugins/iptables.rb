# Encoding: utf-8
# A plugin to discover IPtables rules configured on a server
Ohai.plugin(:Iptables) do
	provides 'iptables'

	collect_data(:linux) do
		iptables Mash.new # Creating a mash of present IPTables rules
		so = shell_out("sudo iptables -S")
		so.stdout.each_line.with_index do |line, i|
			case line
			when /^-P/
				fields = line.strip.split(" ")
				iptables[i] = {
					"type" => "policy",
					"chain" => fields[1],
					"policy" => fields[2]
				}
			when /^-A/
				dict = {}
				clobbered_fields = line.split("-")
				fields = clobbered_fields.map { |field| field.split(" ")}
				fields.each do |field| 
					key = field[0] == "A" ? "chain" : field[0].to_s 
					dict[key] = field[1]
				end
				dict.delete("")
				dict["type"] = "rule"
				iptables[i] = dict
			end
		end
	end
end
