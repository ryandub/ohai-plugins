provides "routes"

lines_v4 = `netstat -nr4`.split(/\n/)[2..-1]
lines_v6 = `netstat -nr6`.split(/\n/)[2..-1]

routes Mash.new
if lines_v4
  routes["inet"] = Array.new
  for line in lines_v4
    line_data = line.split()
    routes["inet"].push({
      :destination => line_data[0],
      :gateway => line_data[1],
      :genmask => line_data[2],
      :flags => line_data[3],
      :mss => line_data[4],
      :window => line_data[5],
      :irtt => line_data[6],
      :iface => line_data[7]
    })
  end
end

if lines_v6
  routes["inet6"] = Array.new
  for line in lines_v6
    line_data = line.split()
    routes["inet6"].push({
      :destination => line_data[0],
      :next_hop => line_data[1],
      :flags => line_data[2],
      :metric => line_data[3],
      :ref => line_data[4],
      :use => line_data[5],
      :iface => line_data[6]
    })
  end
end
