
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



function checkIfSomeOneMayWin {
	
	local row
	local column
	local replaceSymbol=$1
	local checkSymbol=$2
	for (( row=1;row<=3;row++ ))
	do
		for (( column=1;column<=3;column++ ))
		do
			if [ ${board[$row,$column]} = $SPACE ]
			then		
				board[$row,$column]=$checkSymbol
				isWon $row $column
				local won=$?
				if [ $won -eq 1 ]
				then
					board[$row,$column]=$replaceSymbol
					return 1
				else
					board[$row,$column]=$SPACE
				fi
			fi
		done
	done
	return 0
}


function checkForCornersAndPlace {

	local size=3
	local row
	local column
	for (( row=1;row<4;row=row+2 ))
	do
		for (( column=1;column<4;column=column+2))
		do
			fillPositionInBoard $row $column $computerSymbol
			local filled=$?
			if [ $filled -eq 1 ]
			then
			return 1
			fi
		done
	done
	return 0
}

function checkCentre {

local computerSymbol=$1
local row=2
local column=2
if [ ${board[$row,$column]} = $SPACE ]
then
	board[$row,$column]=$computerSymbol
	return 1
fi 
return 0;
}


function fillPositionInBoard {
	
	local row=$1
	local column=$2
	local symbol=$3
	if [ ${board[$row,$column]} = $SPACE ]	
	then
		board[$row,$column]=$symbol
		return 1
	fi 
	return 0

}


function takeAnySide {


local row
local column=1
local size=3
for (( row=2;row<size;row++ ))
do
	if [ ${board[$row,$column]} = $SPACE ]
			then
				board[$row,$column]=$computerSymbol
				return 1
			fi 
done
column=$(($size))
for (( row=2;row<size;row++ ))
do
	if [ ${board[$row,$column]} = $SPACE ]
			then
				board[$row,$column]=$computerSymbol
				return 1
			fi 
done

row=1
for (( column=2;column<size;column++ ))
do
	if [ ${board[$row,$column]} = $SPACE ]
			then
				board[$row,$column]=$computerSymbol
				return 1
			fi 
done

row=$(($size))
for (( column=2;column<size;column++ ))
do
	if [ ${board[$row,$column]} = $SPACE ]
			then
				board[$row,$column]=$computerSymbol
				return 1
			fi 
done




}








function giveTurnToPlayer {
	local playerSymbol=$1
	local row
	local filled=0
	local column
	while [ $filled -eq 0 ]
	do
		read -p "enter row" row
		read -p "enter column" column
		fillPositionInBoard $row $column $playerSymbol
		filled=$?
	done
	result=$(getDecision $row $column)
	if [ result = "won" ]
	then
		echo "you won"
		return 0
	elif [ result = "loss" ]
	then
		echo "tie"
		return 0
	else
		return 1
	fi
}

function giveTurnToComputer {
	
	local row
	local filled=0
	local column
	checkIfSomeOneMayWin $computerSymbol $computerSymbol
	if [ $? -eq 1 ]
	then 
		return 0	
	fi
	checkIfSomeOneMayWin $playerSymbol $computerSymbol
	if [ $? -eq 1 ]
	then 
		return 1	
	fi
	checkForCornersAndPlace
	if [ $? -eq 1 ]
	then
		return 1
	fi	
	checkCentre
	if [ $? -eq 1 ]
	then
		return 1
	fi	
	
	takeAnySide
	if [ $? -eq 1 ]
	then
		return 1
	fi


}


function startTicTacToe {
	initialiseEmptyBoard
	displayBoard
	read playerSymbol computerSymbol< <(getSymbolForPlayer)
	echo "Player Symbol ="$playerSymbol 
	echo "computer Symbol ="$computerSymbol
	chance=$((RAMDOM%2))
	echo "chance = "$chance
	while [ 1 -eq 1 ]
	do	
		if [ $chance -eq 1 ]
		then
			giveTurnToPlayer $playerSymbol
			if [ $? -eq 0 ]
			then
				break
			fi		
			displayBoard
			echo
			chance=0	
		else
			giveTurnToComputer
			if [ $? -eq 0 ]
			then
				break
			fi
			displayBoard

			chance=1	 
		fi
	done
}

startTicTacToe
displayBoard
