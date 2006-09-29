#!/bin/bash
##
## Shows TX/RX over 1sec
## $Id: traf.sh,v 1.7 2006/09/29 18:39:57 mina86 Exp $
## By Michal Nazareicz (mina86/AT/mina86.com)
##  & Stanislaw Klekot (dozzie/AT/irc.pl)
## Released to Public Domain
##

# usage: ./traf.sh <interface>
# <interface> can be a BRE


set -e
INT="${1-eth0}"


get_traffic () {
	TX2=0; RX2=0;
	while read LINE; do
		expr X"${LINE%%:*}" : X".*\\($INT\\)" >/dev/null || continue
		set -- ${LINE#*:}
		RX2=$(( $RX2 + $1 ))
		TX2=$(( $RX2 + $9 ))
	done </proc/net/dev
}


get_traffic

while sleep 1; do
	TX1=$TX2
	RX1=$RX2
	get_traffic

	TX=$(( $TX2 - $TX1 ))
	RX=$(( $RX2 - $RX1 ))

	PT=; PR=;
	I=0
	while [ $I -lt 15360 ]; do
		if [ $I -lt $TX ]; then PT="#$PT"; else PT=" $PT"; fi
		if [ $I -lt $RX ]; then PR="$PR#"; else PR="$PR "; fi
		I=$(( $I + 512 ))
	done
	if [ $TX -gt 2048 ]; then TX="$(( $TX / 1024 )) K"; fi
	if [ $RX -gt 2048 ]; then RX="$(( $RX / 1024 )) K"; fi
#	printf "%s < %6s | %6s > %s\n" "$PT" "$TX" "$RX" "$PR"
	printf "%6s  %s | %s  %6s\n" "$TX" "$PT" "$PR" "$RX"

#	PROGRESS=""
#	I=0
#	while [ $I -lt $TX -o $I -lt $RX ]; do
#		if [ $I -gt $TX ]; then
#			PROGRESS="$PROGRESS'"
#		elif [ $I -gt $RX ]; then
#			PROGRESS="$PROGRESS."
#		else
#			PROGRESS="$PROGRESS:"
#		fi
#		I=$(( $I + 512 ))
#	done
#	if [ $TX -gt 2048 ]; then TX="$(( $TX / 1024 )) K"; fi
#	if [ $RX -gt 2048 ]; then RX="$(( $RX / 1024 )) K"; fi
#	printf "< %6s > %6s  %s\n" "$TX" "$RX" "$PROGRESS"
done
