
#!/bin/bash -x

SPACE="."
declare -A board


function initialiseEmptyBoard {
	local row
	local column
	for (( row=1;row<=3;row++))
	do
		for (( column=1;column<=3;column++ ))
		do
			board[$row,$column]=$SPACE
		done
	done
}


function displayBoard {
	local row
	local column
	for (( row=1;row<=3;row++))
	do
		for (( column=1;column<=3;column++ ))
		do
			echo -n " ${board[$row,$column]}"
			if [ $column -ne 3 ]
			then
				echo -n " |"
			fi			
		done
		echo
		if [ $row -ne 3 ]
		then
		echo -n "------------"
		echo
		fi
	done
}

function getSymbolForPlayer {

	if [ $((RANDOM%2)) -eq 1 ]
	then
		echo "X O"
	else
		echo "O X"
	fi
}


function checkIsRowEqual {

	local row=$1
	local sameRow=1
	local column
	for (( column=1;column<=2;column++ ))
	do
		if [[ ${board[$row,$column]} != ${board[$row,$(($column+1))]} ]] || [ "${board[$row,$column]}" = $SPACE ]
		then
			sameRow=0
			break
		fi
	done
	return $sameRow

}

function checkIsColumnEqual {

	local column=$1
	local sameColumn=1
	local row
	for (( row=1;row<=2;row++ ))
	do
		if [[ ${board[$row,$column]} != ${board[$(($row+1)),$column]} ]] || [ "${board[$row,$column]}" = $SPACE ]
		then
			sameColumn=0
			break
		fi
	done
	return $sameColumn
}

function isDiagonal_1_Equal {
	
	local row=$1
	local column=$2
	local sameDiagonal=1
	if [ $row -eq $column ]
	then
		for (( row=1;row<=2;row++ ))
		do
			if [[ ${board[$row,$row]} != ${board[$(($row+1)),$(($row+1))]} ]] || [ ${board[$row,$row]} = $SPACE ]
			then
				sameDiagonal=0
				break
			fi	
		done
	else
		return 0
	fi
	return $sameDiagonal
}


function isDiagonal_2_Equal {

	local row
	local column
	local sameDiagonal=1
	for (( row=3,column=1;row>=2;row--,column++ ))
	do
		if [[ ${board[$row,$column]} != ${board[$(($row-1)),$(($column+1))]} ]] || [ ${board[$row,$column]} = $SPACE ]
			then
				sameDiagonal=0
				break
			fi		
	done
	return $sameDiagonal
}

function isWon {

local row=$1
local column=$2
checkIsRowEqual $row
local rowEqual=$?
checkIsColumnEqual $column
local columnEqual=$?
isDiagonal_1_Equal $row $column
local diagonal_1_Equal=$?
isDiagonal_2_Equal 
local diagonal_2_Equal=$?

if [ $rowEqual -eq 1 -o $columnEqual -eq 1 -o $diagonal_1_Equal -eq 1 -o $diagonal_2_Equal -eq 1 ]
then
	return 1
else
	return 0
fi

}


function isTie {
	local row
	local column
	for (( row=1;row<=3;row++ ))
	do
		for (( column=1;column<=3;column++ ))
		do
			if [ ${board[$row,$column]} = $SPACE ]
			then
				return 0
			fi
		done
	done
	return 1
}

function getDecision {

local row=$1
local column=$2
isWon $row $column
won=$?
if [ $won -eq 1 ]
then
	echo "won"
fi
isTie
tie=$?
if [ $tie -eq 1 ]
then
	echo "tie"
fi
echo "turn"
}

function checkIfComputerWins {
	
	local row
	local column
	for (( row=1;row<=3;row++ ))
	do
		for (( column=1;column<=3;column++ ))
		do
			if [ ${board[$row,$column]} = $SPACE ]
			then		
				board[$row,$column]=$computerSymbol
				isWon $row $column
				local won=$?
				if [ $won -eq 1 ]
				then
					echo "$computerSymbol won"
					return 1
				else
					board[$row,$column]=$SPACE
				fi
			fi
		done
	done
	return 0
}


initialiseEmptyBoard
board[1,1]="X"
board[3,3]="X"
displayBoard
read playerSymbol computerSymbol< <(getSymbolForPlayer)
echo $playerSymbol $computerSymbol
checkIfComputerWins
win=$?
echo $win


