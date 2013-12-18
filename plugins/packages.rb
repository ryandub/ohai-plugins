require_plugin 'platform_family'

provides 'packages'

packages Mash.new

if platform_family.eql?("debian")
  status, stdout, stderr = run_command(:no_status_check => true,
                                       :command => "dpkg-query -W")

  pkgs = stdout.split("\n")

  pkgs.each do |pkg|
    pkg = pkg.split("\t")
    packages[pkg[0]] = {"version" => pkg[1]}
  end
elsif platform_family.eql?("rhel")
  status, stdout, stderr = run_command(:no_status_check => true,
                                       :command => "rpm -qa --queryformat '%{NAME}: %{VERSION}\n'")

  pkgs = stdout.split("\n")

  pkgs.each do |pkg|
    pkg = pkg.split(": ")
    packages[pkg[0]] = {"version" => pkg[1]}
  end
end
