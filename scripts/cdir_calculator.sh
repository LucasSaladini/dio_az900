#!/bin/bash

# Validates if the argument was inputted correctly
if [[ -z "$1" ]]; then
	echo "Usage: $0 <CIDR or prefix> (i.e. 10.0.1.0/24 or 24)"
	exit 1
fi

# Extracts only the prefix number (remove the IP and forward slash, if present)
PREFIX="${1#*/}"

# Validates if the number is valid and is between the range of 0 to 32
if ! [[ "$PREFIX" =~ ^[0-9]+$ ]] || [ "$PREFIX" -lt 0 ] || [ "$PREFIX" -gt 32 ]; then
	echo "Error: CIDR prefix is invalid ('$PREFIX'). Input a number between 0 and 32."
	exit 1
fi

# Calculates free bits and uses bit-shift (1 << n = 2^n)
HOST_BITS=$((32 - PREFIX))
TOTAL_IPS=$((1 << HOST_BITS))

# Calculates usable IPs considering the reserved default (Network/Broadcast) and Azure reserved IPs (5 IPs)
if [ "$PREFIX" -le 29 ]; then
	STANDARD_USABLE=$((TOTAL_IPS - 2))
	AZURE_USABLE=$((TOTAL_IPS - 5))
elif [ "$PREFIX" -eq 30 ]; then
	STANDARD_USABLE=2 #RFC 3021 (Point-to-Point)
	AZURE_USABLE=0
else
	STANDARD_USABLE=1 # /32 (Unique host)
	AZURE_USABLE=0
fi

echo "----------------------------------------"
echo " Analyzed block    : /$PREFIX"
echo " Host Bits         : $HOST_BITS bits"
echo " Total IPs         : $TOTAL_IPS"
echo " Usable (Default)  : $STANDARD_USABLE (excluding network and broadcast)"
echo " Usable (Azure)    : $AZURE_USABLE (excluding the reserved 5 IPs)"
echo "----------------------------------------"
