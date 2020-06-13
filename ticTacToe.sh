check who plays first

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

function getSymbolForPlayer {

	if [ $((RANDOM%2)) -eq 1 ]
	then
		echo "X"
	else
		echo "0"
	fi
}

initialiseEmptyBoard
playerSymbol=$(getSymbolForPlayer)
echo $playerSymbol
chance=$(getSymbolForPlayer)
echo "chance given to "$chance
