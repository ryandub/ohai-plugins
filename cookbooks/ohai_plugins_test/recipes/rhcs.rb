
bash "rhcs_setup" do
  code <<-EOH
  chkconfig iptables off; service iptables stop
  yum -y install rgmanager ccs
  chkconfig ricci on; service ricci start
  echo 'ricci:$6$BvVGAYEh$BIsvGcfwPy29P9AmwEwD/JyqugwbC24EN1gJmvbU69JRxN76Gwusk5cGt51PgACVLLluDHThTdHSI8EPJbKdb1' | chpasswd -e   
  ccs -h localhost -p rack --createcluster testcluster
  ccs -h localhost -p rack --addnode $(hostname)
  ccs -h localhost -p rack --addresource script name=testresource file=/etc/init.d/netfs
  ccs -h localhost -p rack --addservice script-svc
  ccs -h localhost -p rack --addsubservice script-svc script ref=testresource
  ccs -h localhost -p rack --sync --activate
  ccs -h localhost -p rack --startall
EOH
end