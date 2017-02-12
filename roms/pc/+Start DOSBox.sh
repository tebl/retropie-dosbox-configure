#!/bin/bash
cd `dirname "$0"`
source "DOSBox Settings.lib"
source "DOSBox Functions.lib"

params=("$@")
if [[ -z "${params[0]}" ]]; then
	params=(-conf "$DIR/dosbox.conf")
elif [[ "${params[0]}" == *.sh ]]; then
	bash "${params[@]}"
	exit
else
	BASE=`basename -s .init "$1"`
	if [[ ! -e "$1" ]]; then
		echo "CMD-file specified ($1) does not exist!" >&2
		exit 1
	fi

	params=(-conf "$DIR/dosbox.conf")
	if [[ -e "$DIR/$BASE.conf" ]]; then
		params+=(-conf "$DIR/$BASE.conf")
	fi
	if [[ ! -d "$GAMEDIR/$BASE" ]]; then
		echo "Game folder ($GAMEDIR/$BASE) does not exist!" >&2
		exit 1
	fi

	echo "[autoexec]" > $CONFIG
	echo "mount e \"$GAMEDIR/$BASE\" -label Game" >> $CONFIG
	echo "e:" >> $CONFIG
	cat "$1" >> $CONFIG
	echo >> $CONFIG
	if [[ -e "$DIR/$BASE.debug" ]]; then
		echo "pause" >> $CONFIG
	fi
	echo "exit" >> $CONFIG

	params+=(-conf "$CONFIG")
fi

"/opt/retropie/emulators/dosbox/bin/dosbox" "${params[@]}"
