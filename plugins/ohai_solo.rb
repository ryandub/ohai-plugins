provides "ohai_solo"

def parse_version(versionfile)
  data = File.open(versionfile) {|f| f.readline}.strip
  version = data.split(" ")[1]
  return version
end

ohai_solo Mash.new
ohai_solo[:version] = parse_version("/opt/ohai-solo/version-manifest.txt")
