# Encoding: utf-8
# Report /etc/pam.d configurations

Ohai.plugin(:Pam) do
  depends 'etc'
  provides 'etc/pam'

  def parse_pam_files
    response = {}
    files = Dir.glob('/etc/pam.d/*').select { |f| !File.directory? f }
    files.each do |file|
      name = File.basename(file)
      response[name] = []
      so = shell_out("cat #{file}")
      so.stdout.lines do |line|
        line = strip_comments(line)
        case line
        # rubocop:disable Metrics/LineLength
        when /^(?!#)(\s+)?(password|auth|account|session)\s(\[.*\]|[a-z].*)\s([a-z].*\.so)\s(.*+$)/
          # rubocop:enable Metrics/LineLength
          response[name] << {
            'module_interface' => $2.strip,
            'control_flag' => $3.strip,
            'module_name' => $4.strip,
            'module_arguments' => $5.strip
          }
        end
      end
      response.delete(name) if response[name].empty?
    end
    response
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
    pam = parse_pam_files
    unless pam.empty?
      etc Mash.new unless etc
      etc['pam'] = pam unless pam.empty?
    end
  end
end
