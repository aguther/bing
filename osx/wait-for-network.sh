#!/bin/bash

# define function to determine if network is available or not
is_network_available ()
{
	# determine if network is available by pinging bing.com
	ping -c 1 www.bing.com 1>/dev/null 2>&1

	if [[ $? == 0 ]]; then
		# network is available
		return 0;
	else
		# network is *not* available
		return 1;
	fi
}

# loop to detect if network is available
while true
do
	is_network_available
	if [[ $? == 0 ]]; then
		# network is available, we are done
		exit 0;
	else
		# network is *not* available, keep waiting
		sleep 5;
	fi
done
