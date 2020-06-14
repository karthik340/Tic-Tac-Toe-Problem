
#!/bin/bash -x

SPACE="."
declare -A board
TRUE=1
FALSE=0
WON=1
TIE=2
TURN=3



function initialiseEmptyBoard {
	local row
	local column
	for (( row=1;row<=$SIZE_OF_BOARD;row++))
	do
		for (( column=1;column<=$SIZE_OF_BOARD;column++ ))
		do
			board[$row,$column]=$SPACE
		done
	done
}


function displayBoard {
	local row
	local column
	for (( row=1;row<=$SIZE_OF_BOARD;row++))
	do
		for (( column=1;column<=$SIZE_OF_BOARD;column++ ))
		do
			echo -n " ${board[$row,$column]}"
			if [ $column -ne $SIZE_OF_BOARD ]
			then
				echo -n " |"
			fi			
		done
		echo
		if [ $row -ne $SIZE_OF_BOARD ]
		then
			for (( index=1;index<=$SIZE_OF_BOARD;index++))
			do
				echo -n "----"
			done
		fi
		echo
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


function checkRow {

	local row=$1
	local sameRow=$TRUE
	local column
	for (( column=1;column<=$(($SIZE_OF_BOARD-1));column++ ))
	do
		if [[ ${board[$row,$column]} != ${board[$row,$(($column+1))]} ]] || [ "${board[$row,$column]}" = $SPACE ]
		then
			sameRow=$FALSE
			break
		fi
	done
	echo $sameRow

}

function checkColumn {

	local column=$1
	local sameColumn=$TRUE
	local row
	for (( row=1;row<=$(($SIZE_OF_BOARD-1));row++ ))
	do
		if [[ ${board[$row,$column]} != ${board[$(($row+1)),$column]} ]] || [ "${board[$row,$column]}" = $SPACE ]
		then
			sameColumn=$FALSE
			break
		fi
	done
	echo $sameColumn
}

function isDiagonal {
	
	local row
	local column
	local sameDiagonal1=$TRUE
	local sameDiagonal2=$TRUE
	
	for (( row=1,column=$SIZE_OF_BOARD;row<=$(($SIZE_OF_BOARD-1));row++,column-- ))
	do
		if [[ ${board[$row,$row]} != ${board[$(($row+1)),$(($row+1))]} ]] || [ ${board[$row,$row]} = $SPACE ]
		then
			sameDiagonal1=$FALSE
		fi
		if [[ ${board[$row,$column]} != ${board[$(($row+1)),$(($column-1))]} ]] || [ ${board[$row,$column]} = $SPACE ]
		then
			sameDiagonal2=$FALSE
		fi		
	done	
	
	if [ $sameDiagonal1 -eq $TRUE -o $sameDiagonal2 -eq $TRUE ]
	then
		return $TRUE
	else
		return $FALSE
	fi

}



function isWon {

	local row=$1
	local column=$2
	local rowEqual=$(checkRow $row)
	local columnEqual=$(checkColumn $column)

	isDiagonal
	local diagonal=$?	

	if [ $rowEqual -eq $TRUE -o $columnEqual -eq $TRUE -o $diagonal -eq $TRUE ]
	then
		return $TRUE
	else
		return $FALSE
	fi

}


function isTie {
	local row
	local column
	for (( row=1;row<=$SIZE_OF_BOARD;row++ ))
	do
		for (( column=1;column<=$SIZE_OF_BOARD;column++ ))
		do
			if [ ${board[$row,$column]} = $SPACE ]
			then
				return $FALSE
			fi
		done
	done
	return $TRUE
}

function getDecision {

	local row=$1
	local column=$2
	isWon $row $column
	if [ $? -eq $TRUE ]
	then
		return $WON
	
	fi
	isTie
	if [ $? -eq $TRUE ]
	then
		return $TIE
	fi
	return $TURN
}



function checkIfSomeOneMayWin {
	
	local row
	local column
	local replaceSymbol=$2
	local checkSymbol=$1
	for (( row=1;row<=$SIZE_OF_BOARD;row++ ))
	do
		for (( column=1;column<=$SIZE_OF_BOARD;column++ ))
		do
			if [ ${board[$row,$column]} = $SPACE ]
			then		
				board[$row,$column]=$checkSymbol
				isWon $row $column
				if [ $? -eq $TRUE ]
				then
					board[$row,$column]=$replaceSymbol
					return $TRUE
				else
					board[$row,$column]=$SPACE
				fi
			fi
		done
	done
	return $FALSE
}


function checkForCornersAndPlace {

	local size=$SIZE_OF_BOARD
	local row
	local column
	for (( row=1;row<$(($SIZE_OF_BOARD+1));row=row+$(($SIZE_OF_BOARD-1)) ))
	do
		for (( column=1;column<$(($SIZE_OF_BOARD+1));column=column+$(($SIZE_OF_BOARD+1))))
		do
			fillPositionInBoard $row $column $computerSymbol
			if [ $? -eq $TRUE ]
			then
				return $TRUE	
			fi
		done
	done
	return $FALSE
}

function checkCentre {

	local row=$(($(($SIZE_OF_BOARD+1))/2))
	local column=$(($(($SIZE_OF_BOARD+1))/2))
	if [ ${board[$row,$column]} = $SPACE ]
	then
		board[$row,$column]=$computerSymbol
		return $TRUE
	fi 
	return $FALSE
}


function fillPositionInBoard {
	
	local row=$1
	local column=$2
	local symbol=$3
	if [ ${board[$row,$column]} = $SPACE ]	
	then
		board[$row,$column]=$symbol
		return $TRUE
	fi 
	return $FALSE

}


function takeAnySide {


local row
local column=1
local size=$SIZE_OF_BOARD

for (( row=1;row<=$SIZE_OF_BOARD;row++))
	do
		for (( column=1;column<=$SIZE_OF_BOARD;column++ ))
		do
			if [ $row -eq 1 ] || [ $row -eq $SIZE_OF_BOARD ] && [ $column -ne 1 -a $column -ne $SIZE_OF_BOARD ] 
			then
				if [ ${board[$row,$column]} = $SPACE ]
				then
					board[$row,$column]=$computerSymbol
				return $TRUE
				fi 	
			fi
			
			if [ $column -eq 1 ] || [ $column -eq $SIZE_OF_BOARD ] && [ $row -ne 1 -a $row -ne $SIZE_OF_BOARD ] 
			then
				if [ ${board[$row,$column]} = $SPACE ]
				then
					board[$row,$column]=$computerSymbol
				return $TRUE
				fi 	
			fi
		done
	done

}








function giveTurnToPlayer {
	local playerSymbol=$1
	local row
	local filled=$FALSE
	local column
	while [ $filled -eq $FALSE ]
	do
		read -p "enter row" row
		read -p "enter column" column
		fillPositionInBoard $row $column $playerSymbol
		filled=$?
	done
	getDecision $row $column
	result=$?
	if [ $result = $WON ]
	then
		echo "you won"
		return $TRUE
	elif [ $result = $TIE ]
	then
		echo "tie"
		return $TRUE
	else
		return $FALSE
	fi
}

function giveTurnToComputer {
	
	local row
	local filled=0
	local column
	checkIfSomeOneMayWin $computerSymbol $computerSymbol
	if [ $? -eq $TRUE ]
	then 	echo "computer won"
		return $TRUE	
	fi
	checkIfSomeOneMayWin $playerSymbol $computerSymbol    
	if [ $? -eq $TRUE ]
	then 
		return $FALSE	
	fi
	checkForCornersAndPlace
	if [ $? -eq $TRUE ]
	then
		return $FALSE
	fi	
	checkCentre
	if [ $? -eq $TRUE ]
	then
		return $FALSE
	fi	
	takeAnySide
	if [ $? -eq $TRUE ]
	then
		return $FALSE
	fi


}


function startTicTacToe {
	initialiseEmptyBoard
	displayBoard
	local exit1
	read playerSymbol computerSymbol< <(getSymbolForPlayer)
	echo "Player Symbol ="$playerSymbol 
	echo "computer Symbol ="$computerSymbol
	chance=$((RANDOM%2))
	echo "chance = "$chance
	quit=$FALSE
	while [ $FALSE -eq $quit ]
	do	
		if [[ $chance -eq $FALSE ]]
		then
			chance=$TRUE
			giveTurnToPlayer $playerSymbol
			quit=$?
				
		else
			chance=$FALSE
			giveTurnToComputer	
			if [ $? -eq $FALSE ]
			then
				isTie
				if [ $? -eq $TRUE ]
				then
			     		echo "tie"
					quit=$TRUE		
				fi
			else
				quit=$TRUE
			fi
					
		fi
		displayBoard
		echo
	done
}

read -p "Enter size of board" SIZE_OF_BOARD
startTicTacToe


