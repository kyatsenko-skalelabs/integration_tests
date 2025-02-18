# source it!

# params:
# IPS array of node IPs
# REMORE_USER
# HISTORIC & HISTORIC_IP
# SKALED_RELEASE - dockerhub schain container version
# SGX_URL

REMOTE_USER="${REMOTE_USER:-ubuntu}"
REMOTE_HOME="/home/$REMOTE_USER"
if [ "$REMOTE_USER" = "root" ]
then
  REMOTE_HOME="/root"
fi

#input: $IP, $I
HOST_START () {
	ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$IP <<- ****

	sudo docker run -d --network host -u root -e FILEBEAT_HOST=3.17.12.121:5000 -v $REMOTE_HOME/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro -v /var/lib/docker:/var/lib/docker:ro -v /var/run/docker.sock:/var/run/docker.sock docker.elastic.co/beats/filebeat:7.3.1

	for J in {0..0}
	do

		#mv config.json data_dir/config.json
		mkdir data_dir/\$J

		sed "s/1231,/1\$((2+J))31,/g" config.json > data_dir/\$J/config.json

		#sudo docker start skale-ci-\$J
        if [[ "$IP" != "$HISTORIC_IP" ]]
        then
		    sudo docker run -m 2.4G -d -e catchupIntervalMs=60000 --cap-add SYS_ADMIN --name=skale-ci-\$J -v $REMOTE_HOME/shared_space:/shared_space -v $REMOTE_HOME/skale_node_data:/skale_node_data -v $REMOTE_HOME/data_dir/\$J:/data_dir -p 1\$((2+J))31-1\$((2+J))39:1\$((2+J))31-1\$((2+J))39/tcp -e DATA_DIR=/data_dir -i -t --stop-timeout 300 --restart=always skalenetwork/schain:$SKALED_RELEASE --http-port 1\$((2+J))34 --ws-port 1\$((2+J))33 --config /data_dir/config.json -d /data_dir --ipcpath /data_dir -v 4 --web3-trace --enable-debug-behavior-apis --aa no --sgx-url ${SGX_URL} --shared-space-path /shared_space/data $PARAMS
        else
		    sudo docker run -d -e catchupIntervalMs=60000 --cap-add SYS_ADMIN --name=skale-ci-\$J -v $REMOTE_HOME/shared_space:/shared_space -v $REMOTE_HOME/skale_node_data:/skale_node_data -v $REMOTE_HOME/data_dir/\$J:/data_dir -p 1\$((2+J))31-1\$((2+J))39:1\$((2+J))31-1\$((2+J))39/tcp -e DATA_DIR=/data_dir -i -t --stop-timeout 300 --restart=always skalenetwork/schain:${SKALED_RELEASE}-historic --http-port 1\$((2+J))34 --ws-port 1\$((2+J))33 --config /data_dir/config.json -d /data_dir --ipcpath /data_dir -v 4 --web3-trace --enable-debug-behavior-apis --aa no --shared-space-path /shared_space/data
        fi
	done

	cd skaled_monitor
	sudo ./node-side-monitor.sh </dev/null 2>/dev/null >/dev/null &
	cd ..

	****
}

I=0
for IP in ${IPS[*]} #:0:11}
do
    if [[ $I -ge 6 && $I -le 8 ]]
    then
        IP=$IP HOST_START&
#        IP=$IP PARAMS="--download-snapshot dummy" HOST_START&
    else
        IP=$IP HOST_START&
    fi
	I=$((I+1))
done

if $HISTORIC
then
	IP=$HISTORIC_IP HOST_START&
fi

wait

sleep 30	# sometimes transaction script cannot connect, so wait
