#!/bin/bash
net_addr_default="192.168.1.1"
read -p "Enter the IP address of iPerf3 server [Default: $net_addr_default]: " network_address

if [[ $network_address == "" ]]; then
	network_address=$net_addr_default
fi

echo "Step (1/4)" && \
iperf3 -c $network_address && \
echo "Step (2/4)" && \
iperf3 -c $network_address -R && \
echo "Step (3/4)" && \
iperf3 -c $network_address -u -b 1000M && \
echo "Step (4/4)" && \
iperf3 -c $network_address -u -b 1000M -R 
read -p "Press [Enter] to exit" quit_key
