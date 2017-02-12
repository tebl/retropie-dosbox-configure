#!/bin/bash
cd `dirname "$0"`
source "DOSBox Settings.lib"
source "DOSBox Functions.lib"

function select_game() {
	while true; do
		let i=0
		W=()
		F=()
		while read -r line; do
			let i=$i+1
			F[$i]="$line"
			if file_exists "$line.init"; then
				if file_exists "$line.conf"; then
					W+=($i "[C] $line")
				else
					W+=($i "[I] $line")
				fi
			else
				W+=($i "[ ] $line")
			fi
		done < <( ls -1 $GAMEDIR/ )
		GAME=$(dialog --ascii-lines --backtitle "$TITLE" --title " Game menu " --menu "Select a game from the list:" 30 80 22 "${W[@]}" 2>&1 1>/dev/tty)
		if [ $? -eq 0 ]; then
			select_option "${F[$GAME]}"
		else
			break
		fi
	done
}

function select_option() {
	GAME="$1"
	while true; do
		OPTIONS=(--ascii-lines --backtitle "$TITLE" --title " $GAME")
		OPTIONS+=(--menu "Select action:" 30 80 22)
		OPTIONS+=("Game" "")
		OPTIONS+=(" SelectExe" "Select file to run")
		if file_exists "$GAME.init"; then OPTIONS+=(" ShowCMD" "Show game startup commands"); fi
		OPTIONS+=(" EditCMD" "Manually edit game startup commands")

		if file_exists "$GAME.debug"; then
			OPTIONS+=(" Debug" "Enable debug (pause before exit)")
		else
			OPTIONS+=(" Debug" "Disable debug (no pause before exit)")
		fi


		OPTIONS+=("DOSBox" "")
		if file_exists "$GAME.conf"; then OPTIONS+=(" ShowConf" "Show custom configuration"); fi
		OPTIONS+=(" EditConf" "Manually edit customized DOSBox configuration")

		if is_disabled "$GAME.conf" "xms"; then
			OPTIONS+=(" ToggleXMS" "Enable XMS (Extended Memory)")
		else
			OPTIONS+=(" ToggleXMS" "Disable XMS (Extended Memory)")
		fi

		if is_disabled "$GAME.conf" "ems"; then
			OPTIONS+=(" ToggleEMS" "Enable EMS (Expanded Memory Manager)")
		else
			OPTIONS+=(" ToggleEMS" "Disable EMS (Expanded Memory Manager)")
		fi

		OPTIONS+=("Cleanup" "")
		OPTIONS+=(" RemoveConf" "Remove game configurations")

		OPT=$("dialog" "${OPTIONS[@]}" 2>&1 1>/dev/tty)
		if [ $? -eq 0 ]; then
			case $OPT in
				" SelectExe") select_exe "$GAME";;
				" ShowCMD") show_cmd "$GAME";;
				" EditCMD") edit_cmd "$GAME";;
				" Debug") toggle_debug "$GAME";;
				" ShowConf") show_conf "$GAME";;
				" EditConf") edit_conf "$GAME";;
				" ToggleXMS") toggle_option "$GAME.conf" "xms";;
				" ToggleEMS") toggle_option "$GAME.conf" "ems";;
				" RemoveConf") remove_conf "$GAME";;
			esac
		else
			break
		fi
	done
}

function select_exe() {
	GAME="$1"
	let i=0
	W=()
	F=()
	while read -r line; do
		let i=$i+1
		line=$(basename "$line")
		W+=($i "$line")
		F[$i]="$line"
	done < <( find "$GAMEDIR/$GAME" -maxdepth 1 -iname '*.exe' -o -iname '*.bat' -o -iname '*.com' )
	OPT=$(dialog --ascii-lines --backtitle "$TITLE" --title " $GAME " --menu "Select main executable from list:" 30 80 17 "${W[@]}" 2>&1 1>/dev/tty)
	if [ $? -eq 0 ]; then
		set_cmd "$GAME" "${F[$OPT]}"
	fi
}

function set_cmd() {
	GAME="$1"
	CMD="$2"
	if [ ${CMD: -4} == ".bat" ]; then
		CMD="call $CMD"
	fi
	echo "$CMD" > "$GAME.init"
	show_dialog "$GAME" "$GAME startup command has been set to:\n\n$CMD"
}

function show_cmd() {
	GAME="$1"
	if [[ -e "$GAME.init" ]]; then
		CONTENT=$(cat "$GAME.init")
		show_dialog "Game startup command list" "$CONTENT"
	else
		show_error "Game startup command list" "Startup command list for '$GAME' has not been specified yet!"
	fi
}

function edit_cmd() {
	edit_file "$1.init"
}

function toggle_debug() {
	GAME="$1"
	if [[ -e "$GAME.debug" ]]; then
		rm "$GAME.debug"
	else
		touch "$GAME.debug"
	fi
}


function show_conf() {
	GAME="$1"
	if [[ -e "$GAME.conf" ]]; then
		CONTENT=$(cat "$GAME.conf")
		show_dialog "Custom DOSBox Configuration" "$CONTENT"
	else
		show_error "Custom DOSBox Configuration" "Custom DOSBox configuration for game '$GAME' has not been created (default will be used)!"
	fi
}

function edit_conf() {
	edit_file "$1.conf"
}

function remove_conf() {
	GAME="$1"
	if show_confirm "Delete configuration" "Delete configuration for '$GAME' (this will only remove files created by this script)?"; then
		rm -f "$GAME.init" "$GAME.conf" "$GAME.debug"
		show_dialog "Configuration removed" "Game configuration for '$GAME' has been removed!"
		break
	fi
}

select_game
