Ohai.plugin(:Webapps) do
  provides 'webapps'

  collect_data do
    webapps Mash.new
  end
end
