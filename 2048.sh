#!/bin/bash

function pack() {
	sed -e 's/  *//g' \
		-e 's/99/A/g' \
		-e 's/88/9/g' \
		-e 's/77/8/g' \
		-e 's/66/7/g' \
		-e 's/55/6/g' \
		-e 's/44/5/g' \
		-e 's/33/4/g' \
		-e 's/22/3/g' \
		-e 's/11/2/g' \
		-e 's/00/1/g'
}

function print_board() {
	echo '+----+'
	sed 's/.*/|&|/g'
	echo '+----+'
}

function pad() {
	sed	-e 's/^$/&    /' \
		-e 's/^.$/&   /' \
		-e 's/^..$/&  /' \
		-e 's/^...$/& /'
}

function trans() {
	local i j idx BOARD

	BOARD="$(cat)"

	for i in 0 1 2 3; do
		for j in 0 1 2 3; do
			idx=$[$j*5+$i]
			echo -n "${BOARD:$idx:1}"
		done
		echo
	done
}

function spaces() {
	local i j idx BOARD

	BOARD="$(cat)"

	for i in 0 1 2 3; do
		for j in 0 1 2 3; do
			idx=$[$i*5+$j]

			if [ "${BOARD:$idx:1}" = ' ' ]; then
				echo $i $j
			fi
		done
	done
}

function pick_space() {
	spaces | rl | head -1
}

function pick_tile() {
	{ yes 0 | head -9; echo 1; } | rl | head -1
}

function repl() {
	local i=$1 j=$2 c=$3 offset BOARD

	BOARD="$(cat)"

	offset=$[$i*5+$j]

	head -c $offset <<<"$BOARD"
	echo -n $c
	tail -c $[20-$offset-1] <<<"$BOARD"
}

function spawn_tile() {
	local i j c offset BOARD

	BOARD="$(cat)"

	pick_tile | {
		read tile

		pick_space <<<"$BOARD" | {
			read i j

			if [ -z "$i" ]; then
				echo you lose
				exit
			fi

			repl $i $j $tile <<<"$BOARD"
		}
	}
}

function left() {
	pack | pad
}

function right() {
	rev | pack | pad | rev
}

function up() {
	trans | left | trans
}

function down() {
	trans | right | trans
}

BOARD=$(yes '    ' | head -4 | spawn_tile | spawn_tile)

while true; do
	clear
	print_board <<<"$BOARD"

	read -n 1
	case $REPLY in
		h) ACTION=left ;;
		j) ACTION=down ;;
		k) ACTION=up ;;
		l) ACTION=right ;;
		*) ACTION=echo ;;
	esac

	BOARD="$($ACTION <<<"$BOARD")"

	if ! grep ' ' >/dev/null <<<"$BOARD"; then
		echo -e '\ryou lose'
		exit;
	fi

	BOARD="$(spawn_tile <<<"$BOARD")"

	if grep A >/dev/null <<<"$BOARD"; then
		echo -e '\ryou win'
		exit;
	fi
done
