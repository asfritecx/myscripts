#!/bin/bash
# IPTables Testing script
# For Testing iptable rules

BACKUPPATH="$HOME/rulesbackup"
IPTABLEBIN="$(which iptables)"
IPTABLERESTOREBIN="$(which iptables-restore)"
IPTABLESAVEBIN="$(which iptables-save)"

function displayUsageInfo {

cat << EOF
	
Usage Instructions:

./testiptablerule.sh run

This script will run the rule specified and wait for 30 seconds for a yes respond from the user
if no input is provided, the backup rule will be applied and the Test Rule will be removed.

EOF
}

function testiptrule {

	# Backup the IP Tables 
	$IPTABLESAVEBIN > $BACKUPPATH
	
	if [ -e $BACKUPPATH ]
	then
		echo "IP Tables Backed up to $BACKUPPATH"
		echo ""
	else
		echo "Hmm..Backup Seems to not exist..exiting"
		exit		
	fi
	
	# Get Test Rule from user
	echo "Enter The Rule To Test: "
	echo "Example: -I INPUT 1 -s 192.168.0.5 -j ACCEPT"
	echo ""
	read RULETOTEST
	$IPTABLEBIN $RULETOTEST 2>/dev/null

	# Sleeps and checks for respond after applying the test rule
	if [ $? -eq 0  ]
	then
		echo 'Sleeping for 5 seconds'
		sleep 5
		checkForRespond
	else
		echo 'Seems like something went wrong...'
		echo 'Check your IP Tables syntax. Type "man iptables"'
		exit
	fi

	echo "Printing Current IP Table Rules:"
	echo ""
	$IPTABLEBIN -nvL --line-numbers
	echo "Script Finished Execution"
	exit
}


function checkForRespond {

	echo ""
	echo "Please Type y in 30 seconds: "
	read -t 30 check
	if [ $? -eq 0  ] 
	then
		if [ $check = 'y' ]
		then	
			echo "Response Received. Script Will Now Exit..."
			echo "Printing Current IP Table Rules For Verification:"
			echo ""
			$IPTABLEBIN -nvL --line-numbers
			exit
		else
			echo "Something Went Wrong..."
			exit
		fi
	else
		runBackupRule
		exit
	fi
	
}

function runBackupRule {

	# Restore Rule From Backup location
	$IPTABLERESTOREBIN $BACKUPPATH
	echo " "
	echo "IP Tables Restored From Backup As no response was received from the user"
}

function checkForRoot {

	if [ $UID -ne 0 ]
	then
		echo "Please Run Script using SUDO"
		exit
	fi
}


# Function Calling
checkForRoot

if [[ $1 != run ]]
then
	displayUsageInfo
else
        testiptrule $1
fi

exit
