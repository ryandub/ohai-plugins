# Encoding: utf-8
Ohai.plugin(:Rhcs) do
  provides 'rhcs_services', 'rhcs_nodes'

  def retrieve_node_info
    rhcs_nodes Mash.new
    so = shell_out('clustat | grep rgmanager | '\
                   "awk '{ print $1, $2, $3 }' | tr -d ','")
    so.stdout.lines do |line|
      line = line.split(' ')
      info = line.shift(6)
      svc = info[0]
      rhcs_nodes[svc] = Mash.new
      rhcs_nodes[svc][:id] = info[1]
      rhcs_nodes[svc][:state] = info[2]
    end
    return rhcs_nodes
  end

  def retrieve_service_info
    rhcs_services Mash.new
    so = shell_out("clustat | grep service: | awk '{ print $1, $2 , $3}'")
    so.stdout.lines do |line|
      line = line.split(' ')
      info = line.shift(6)
      svc = info[0]
      rhcs_services[svc] = Mash.new
      rhcs_services[svc][:node] = info[1]
      rhcs_services[svc][:state] = info[2]
      so = shell_out("clustat -x | grep #{svc} | "\
                     "sed 's/.*last_transition_str=//' | tr -d '\"/>'")
      rhcs_services[svc][:state_last_changed] = so.stdout.strip
    end
    return rhcs_services
  end

  def clustat_bin
    unless @clustat_bin
      so = shell_out("/bin/bash -c 'command -v clustat'")
      clustat_bin = so.stdout.strip
    end
    return clustat_bin unless clustat_bin.empty?
  end

  collect_data(:linux) do
    if clustat_bin
      retrieve_node_info
      retrieve_service_info
    end
  end
end
