Ohai.plugin(:Vulnerabilities) do
  provides 'vulnerabilities'

  depends 'platform'

  def list_cves(platform_family)
    cves = []

    if platform_family == 'rhel'
      so = shell_out("rpm -qa --changelog |grep 'CVE-'")
      so.stdout.lines do |line|
        cve = line.gsub(/.*CVE-/, 'CVE-')[0..12]
        cves << cve
      end
    elsif platform_family == 'debian'
      so = shell_out("zcat /usr/share/doc/*/changelog.Debian.gz |grep 'CVE-'")
      so.stdout.lines do |line|
        cve = line.gsub(/.*CVE-/, 'CVE-')[0..12]
        cves << cve
      end
    else
      fail("Unsupported OS family #{platform_family}")
    end
    return cves.sort!.uniq
  end

  collect_data(:linux) do
    vulnerabilities Mash.new
    vulnerabilities[:patched_CVE] = list_cves(platform_family)
  end
end
