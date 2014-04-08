# Encoding: utf-8
Ohai.plugin(:Wordpress) do
  depends 'webapps'
  depends 'apache2'

  provides 'webapps/wordpress'

  def get_docroots
    docroots = {}
    unless apache2['vhosts'].empty?
      # Build hash of docroots to iterate
      apache2['vhosts'].each do |vhost_name, vhost|
        vhost.each do |site_name, site|
          docroots[site_name] = site['docroot']
        end
      end
    end
    return docroots unless docroots.empty?
  end

  def get_version(path)
    version = nil
    version_file = File.join(File.dirname(path), 'wp-includes/version.php')
    file = File.open(version_file)
    begin
      file.each_line do |line|
        if /wp_version =/.match(line)
          version = line.split('=')[1].gsub(/\'|\;/, '').strip
          break
        end
      end
    ensure
      file.close
    end
    return version if version
  end

  def find_plugins(path)
    plugins = {}
    dirs = Dir.glob(File.join(File.dirname(path), '/wp-content/plugins/*')).select { |f| File.directory? f }
    dirs.each do |dir|
      files = Dir.glob(File.join(dir, '*.php')).select { |f| !File.directory? f }
      # Read php files to find plugin metadata. Stop when data is found.
      files.each do |php_file|
        begin
          file = File.open(File.join(php_file))
          name = nil
          version = nil
          file.each_line do |line|
            if line =~ /Version: /
              version = line.split(':')[1].strip
              puts version
            elsif line =~ /Plugin Name: /
              name = line.split(':')[1].strip
              puts name
            elsif name && version
              plugins[name] = {}
              plugins[name]['version'] = version
              files = []
              break
            end
          end
        ensure
          file.close if file
        end
        break if files.empty?
      end
    end
    return plugins unless plugins.empty?
  end

  def find_wordpress(docroots)
    require 'find'
    found = {}
    docroots.each do |site_name, site_path|
      excludes = ['.git', '.svn', 'images', 'includes', 'lib', 'wp-content',
                  'wp-includes']
      max_depth = site_path.scan(/\//).count + 3
      Find.find(site_path) do |path|
        # Do not traverse excluded directories and stop
        # once max_depth is reached.
        Find.prune if excludes.include?(File.basename(path))
        Find.prune if path.scan(/\//).count > max_depth
        if path.include?('wp-config.php')
          found[site_name] = {}
          found[site_name]['path'] = path
          found[site_name]['version'] = get_version(path)
          plugins = find_plugins(path)
          found[site_name]['plugins'] = plugins if plugins
          break
        end
      end
    end
    return found unless found.empty?
  end

  collect_data do
    docroots = get_docroots
    found = find_wordpress(docroots) unless docroots.nil?
    webapps['wordpress'] = found unless found.nil?
  end
end
