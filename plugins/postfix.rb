Ohai.plugin(:Postfix) do
  provides 'postfix'
  depends 'packages'

  def find_postfix_executable
    so = shell_out("/bin/bash -c 'command -v postfix'")
    postfix_bin = so.stdout.strip
    return postfix_bin unless postfix_bin.empty?
  end

  def find_postfix_process
    unless @postfix_process
      postfix_process = {}
      so = shell_out("ps aux | grep [m]aster | awk '{print $2 \", \"$11}' ")
      if !so.stdout.empty?
        ps_output = so.stdout.split(', ')
        postfix_process = { 'Master Process PID' => ps_output[0].chomp,
                            'Master Process' => ps_output[1].chomp }
      else
        postfix_process = { 'Master Process' => 'Postfix is not running!' }
      end
    end
    return postfix_process
  end

  def check_postfix_configuration
    postconf = {}
    response = {}

    important_keys = {
      'inet_interfaces' => 'Postfix Listening On Addresses',
      'inet_protocols' => 'IP protocols in use',
      'myhostname' => 'Postfix Hostname',
      'mydomain' => 'Postfix Domain Name',
      'mydestination' => 'Postfix Final Destinations',
      'mynetworks' => 'Postfix Trusted Client Networks',
      'myorigin' => 'Postfix Origin Address',
      'alias_database' => 'Postfix Aliases Database',
      'config_directory' => 'Postfix Configuration Directory',
      'queue_directory' => 'Postfix Queue Directory'
    }

    postconf_output = shell_out('postconf')

    postconf_output.stdout.lines do |line|
      fields = line.split(' = ')
      postconf[fields[0]] = fields[1].strip if fields[1]
    end

    important_keys.each do |key, value|
      response[value] = postconf[key]
    end
    response[:"Postfix Configuration Files"] = Dir.glob(
      postconf['config_directory'] + '/*')
    return response
  end

  # check the size of mail queue without impact (without running mailq command)

  def get_file_paths(path)
    Dir.glob(path + '/**/*').each do |f|
      yield f
    end
  end

  def check_mailq_size
    response = {}
    mail_queue_output = shell_out('postconf -h queue_directory')
    mail_queue_directory = mail_queue_output.stdout.strip
    queue_keys = {
      'incoming' => 'Incoming Mail',
      'active' => 'Active Mail',
      'deferred' => 'Deferred Mail',
      'bounce' => 'Bounced Mail',
      'hold' => 'Hold Mail',
      'corrupt' => 'Corrupt Mail'
    }
    postfix_queues = {
      'incoming' => 0,
      'active' => 0,
      'deferred' => 0,
      'bounce' => 0,
      'hold' => 0,
      'corrupt' => 0
    }
    temporary_array = []
    postfix_queues.each do |queue, _size|
      # without the extra / it does not work!
      path = mail_queue_directory + '/' + queue
      files = get_file_paths(path) { |f| temporary_array << f }
      postfix_queues[queue] = files.length
    end

    queue_keys.each do |key, value|
      response[value] = postfix_queues[key]
    end

    return response
  end

  collect_data(:linux) do
    postfix_binary = find_postfix_executable
    if postfix_binary
      postfix Mash.new
      postfix[:postfix_binary] = postfix_binary
      postfix[:postfix_package] = packages[:postfix]
      postfix[:process] = find_postfix_process
      postfix[:current_configuration] = check_postfix_configuration
      postfix[:mail_queue_sizes] = check_mailq_size
    end
  end
end
