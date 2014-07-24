execute "use_ipv4" do
  command "echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6"
end
