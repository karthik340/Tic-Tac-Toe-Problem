#!/bin/bash -x

SPACE=" "
declare -A board

function initialiseEmptyBoard {
	for (( row=1;row<=3;row++))
	do
		for (( column=1;column<=3;column++ ))
		do
			board[$row,$column]=$SPACE
		done
	done
}

initialiseEmptyBoard
