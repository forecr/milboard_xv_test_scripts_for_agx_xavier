#!/bin/bash
if [ "$(whoami)" != "root" ] ; then
	echo "Please run as root"
	echo "Quitting ..."
	exit 1
fi

# Check the scipts' folder
SCRIPTS_FOLDER=${PWD}
if [ $# -eq 1 ]; then
	SCRIPTS_FOLDER=$1
fi
if [ $# -gt 1 ]; then
	echo "Please type test scripts' folder path"
	echo "Please run as:"
	echo "sudo $0 <test_scripts'_full_path>"
	echo "Quitting ..."
	exit 1
fi
if [ -d "$SCRIPTS_FOLDER" ]; then
	if [ "${SCRIPTS_FOLDER: -1}" != "/" ]; then
		SCRIPTS_FOLDER="$SCRIPTS_FOLDER/"
	fi
	echo "$SCRIPTS_FOLDER folder exists"
	chmod +x $SCRIPTS_FOLDER/enable_can_agx.sh
	chmod +x $SCRIPTS_FOLDER/iperf3_*.sh
else
	echo "$SCRIPTS_FOLDER folder does not exist"
	echo "Quitting ..."
	exit 1
fi

function apt_install_pkg {
	REQUIRED_PKG=$1
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	echo "Checking for $REQUIRED_PKG: $PKG_OK"
	if [ "" = "$PKG_OK" ]; then
		echo ""
		echo "$REQUIRED_PKG not found. Setting it up..."
		sudo apt-get --yes install $REQUIRED_PKG 

		PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
		echo ""
		echo "Checking for $REQUIRED_PKG: $PKG_OK"

		if [ "" = "$PKG_OK" ]; then
			echo ""
			echo "$REQUIRED_PKG not installed. Please try again later"
			exit 1
		fi

	fi
}

# Check GtkTerm installed
apt_install_pkg 'gtkterm'



function test_menu {
	continue_test=true

	while $continue_test; do
		sleep 1
		echo ""
		echo "****************************"
		echo "*** Production Test Menu ***"
		echo "1) Previous Tests"
		echo "2) Disks (M.2 SSD and SD card) Test"
		echo "3) Local Network Test (iperf3)"
		echo "4) Public Network Test (ping)"
		echo "5) USB Test"
		echo "6) RS-232_1 Test"
		echo "7) RS-232_2 Test"
		echo "8) RS-232_3 Test"
		echo "9) RS-232_4 Test"
		echo "10) RS-422_1 Test"
		echo "11) RS-422_2 Test"
		echo "12) RS-422_3 Test"
		echo "13) RS-422_4 Test"
		echo "14) CAN Bus-1 (Send) Test"
		echo "15) CAN Bus-1 (Receive) Test"
		echo "16) CAN Bus-2 (Send) Test"
		echo "17) CAN Bus-2 (Receive) Test"
		read -p "Type the test number (or quit) [1/.../q]: " choice
		echo ""

		case $choice in
			1 ) 
				echo "* Check The power button"
				echo "* Set the device in recovery mode, connect recovery USB and check the device in recovery mode with lsusb"
				echo "* Reset the device, connect to the Debug port and check the serial connection"
				;;
			2 )
				echo "Check M.2 SSD and SD card detected"
				gnome-terminal -- gnome-disks
				;;
			3 )
				read -p "Server or Client (s/c): " network_choice
				case $network_choice in
					[Ss]* )
						gnome-terminal -- $SCRIPTS_FOLDER/iperf3_server.sh
						;;
					[Cc]* )
						gnome-terminal -- $SCRIPTS_FOLDER/iperf3_client.sh
						;;
					* )
						echo "Wrong choice"
						;;
				esac
				;;
			4 )
				echo "(1/2) Ping Test"
				ping -c 5 www.google.com
				echo "(2/2) Network Speed Test"
				ip -br address | grep UP
				# Add parsing command instead of getting network name from user
				read -p "Enter the network name: " net_name
				echo "Check the ethernet connection ($net_name) speed as 1000 Mb/s"
				sudo ethtool $net_name | grep Speed
				;;
			5 )
				echo "Check all USB devices"
				gnome-terminal -- watch -n 0.1 lsusb
				;;
			6 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR4 -s 115200
				;;
			7 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR5 -s 115200
				;;
			8 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR6 -s 115200
				;;
			9 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR7 -s 115200
				;;
			10 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR0 -s 115200
				;;
			11 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR1 -s 115200
				;;
			12 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR2 -s 115200
				;;
			13 )
				sudo gnome-terminal -- gtkterm -p /dev/ttyXR3 -s 115200
				;;
			14 )
				$SCRIPTS_FOLDER/enable_can_agx.sh
				gnome-terminal -- cangen can0 -v
				;;
			15 )
				$SCRIPTS_FOLDER/enable_can_agx.sh
				gnome-terminal -- candump can0
				;;
			16 )
				$SCRIPTS_FOLDER/enable_can_agx.sh
				gnome-terminal -- cangen can1 -v
				;;
			17 )
				$SCRIPTS_FOLDER/enable_can_agx.sh
				gnome-terminal -- candump can1
				;;
			[Qq]* )
				echo "Quitting ..."
				exit 1
				;;
			* )
				echo "Wrong choice"
				;;
		esac
	done
}


test_menu

