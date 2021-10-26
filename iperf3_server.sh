#!/bin/bash
echo "Available networks:"
ip -br address | grep UP
iperf3 -s
