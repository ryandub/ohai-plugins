# Encoding: utf-8
Ohai.plugin(:ProcessesDeletedLibraries) do
  provides 'processes/deleted_libraries'
  depends 'processes'

  collect_data(:linux) do
    so = shell_out('find /proc -maxdepth 2 -name maps -exec grep ' \
                   '-HE \'*\.so.* \(deleted\)\' {} \; | ' \
                   'awk -F \' \' \'{print $1,$6}\'|sed \'s/:.*\s/ /;' \
                   's/\/proc\///;s/\/maps//\'|sort -u')
    so.stdout.lines do |line|
      pid = line.split(' ')[0]
      lib = line.split(' ')[1]
      processes[pid] = {} if processes[pid].nil?
      processes[pid]['deleted_libraries'] = [] if processes[pid][
        'deleted_libraries'].nil?
      processes[pid]['deleted_libraries'] << lib
    end
  end
end
