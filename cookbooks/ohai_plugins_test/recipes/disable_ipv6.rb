execute "use_ipv4" do
  command "echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6"
end
