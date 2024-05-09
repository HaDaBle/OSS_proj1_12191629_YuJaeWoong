#!/bin/bash

function SonData {

	cat players.csv | awk -F,  '$1=="Heung-Min Son" {print "Team : " $4 " Apperance : " $6 " Goal : " $7 " Assist : " $8}';
}

function teamData { 
	read -p "What do you want to get the team data of league_position[1~20] : " rank
	if (( $rank >= 1 && $rank <=20 ))
	then
	
		cat teams.csv | awk -F, -v a=$rank '$6==a {print $1, $2/($2+$3+$4)}'; 
	else
		echo "Wrong Input"
	fi
}

function top3 {
	cat matches.csv | sort -t, -nk2 -r | head -n 3 | awk -F, '{print $3 "  vs  " $4 " (" $1 ")"" \n" $2 " " $7}'
	
}

function positionData {
	cat teams.csv | awk -F, 'NR>1 {print $1 "," $6}' | sort -t,  -k2,2n > temp_team.csv
	declare -a team_names
	while IFS=, read -r name rank;
	do
		team_names+=("$name")
	done < <(awk -F, '{print $1}' temp_team.csv)
	i=1
	for team in "${team_names[@]}";
	do
		echo "$i : $team"
		awk -F, -v team="$team" '$4 == team {print $1 "," $7}' players.csv > temp_player.csv
		cat temp_player.csv | sort -t, -nk2 -r | head -n 1
		i=$(($i+1))
	done
	$(rm temp_team.csv)
	$(rm temp_player.csv)
}
function changeMonth {
    case "$1" in
        Jan) echo "01" ;;
        Feb) echo "02" ;;
        Mar) echo "03" ;;
        Apr) echo "04" ;;
        May) echo "05" ;;
        Jun) echo "06" ;;
        Jul) echo "07" ;;
        Aug) echo "08" ;;
        Sep) echo "09" ;;
        Oct) echo "10" ;;
        Nov) echo "11" ;;
        Dec) echo "12" ;;
        *) echo "??" ;;
    esac
}


function GMTData {
    GMT=$(awk -F, 'NR > 1 { print $1 }' matches.csv | head -n 10)
    echo "$GMT" | while read -r date;
    do
        formatted=$(echo "$date" | sed -E 's/^([A-Za-z]{3}) ([0-9]{1,2}) ([0-9]{4}) - ([0-9]{1,2}:[0-9]{2}[ap]m)$/\1,\2,\3,\4/')
        IFS=',' read -r month day year time <<< "$formatted"
        month_num=$(changeMonth "$month")
        echo "$year/$month_num/$day $time"
    done
}


function winningData {

	first=$(awk -F, 'NR>1 {print $1}' teams.csv | head -n 10)
	second=$(awk -F, 'NR>1 {print $1}' teams.csv | tail -n 10)
	IFS=$'\n' read -rd '' -a first_array <<<"$first"
	IFS=$'\n' read -rd '' -a second_array <<<"$second"
	for i in {0..9};  
	do
    	first_num=$((i + 1))
	first_team="${first_array[$i]}"
	second_num=$((11 + i))
    	second_team="${second_array[$i]}"
	printf "%2d) %-30s %2d) %-30s\n" "$first_num" "$first_team" "$second_num" "$second_team"
	done
	read -p "Enter your team number : " num
	if (( $num >= 1 && $num <=20 ))
	then
		team=$(awk -F, -v r="$num" 'NR-1== r {print $1}' teams.csv)
		awk -F, -v team="$team" '$3 == team { point = $5 - $6; print $1,",",$3,",",$4,",",$5,","$6,",",point}' matches.csv > temp.csv
		cat temp.csv | sort -t, -r -nk6 > sortedTemp.csv;
		$(rm temp.csv)
		max=$(awk -F, '{print $6}' sortedTemp.csv | head -n 1);
		awk -F, -v point="$max" '$6==point {
			print $1 "\n" $2 $4 " vs " $5 $3}' sortedTemp.csv;
		$(rm sortedTemp.csv);
	else
		echo "Wrong Input"
	fi
	
}
function execute {
	if [ $1 ==  "y" ] || [ $1 == "Y" ];
	then
		$2
	elif [ $1 == "n" ] || [ $1 == "N" ];
	then
		echo "skip";
	else
		echo "Please Enter Y or N";
	fi
}
function menu {
	while true
	do
		echo "-------------------------------------------------------------------";
		echo "[MENU]";
		echo "1.Get the data of Heung-Min-Son's Current Club, Apperarances, Goals, Assists in players.csv";
		echo "2.Get the team data to enter a league position in teams.csv";
		echo "3.Get the Top-3 Attendance matches in matches.csv";
		echo "4.Get the team's league position and team's top soccer in teams.csv & players.csv";
		echo "5.Get the modified format of date_GMT in matches.csv";
		echo "6.Get the data of winning team by the largest difference home stadium in teams.csv & matches.csv";
		echo "7.Exit";
		read -p "Enter your CHOICE(1~7) : " c
		case $c in
			1) read -p "Do you want to get the Heung-Min Son's Data? (y/n) :" tmp
				execute $tmp SonData ;;
			2) teamData ;;
			3) read -p "Do you want to know Top-3 attendance data and average attendance?(y/n) :" tmp
				execute $tmp top3 ;;
			4) read -p "Do you want to get each team's ranking and the highest-scoring player?(y/n) :" tmp
				execute $tmp positionData ;;
			5) read -p "Do you want to modify the format of date?(y/n) :" tmp
				execute $tmp GMTData ;;
			6) winningData ;;
			7) echo "Bye!"; break ;;
			*) echo "Please Enter 1~7" ;;
		esac;
	done;
}

function checkCsv {

	for i in "$@";
	do
  	if [[ "$i" == "players.csv" ]] || [[ "$i" == "matches.csv" ]] || [[ "$i" == "teams.csv" ]]; then
  		continue;
 	else
    		echo "$i is not csv that this program need"
    		return 1;
  	fi
	done
	return 0;


}
if [ $# -ne 3 ]; then 
	echo "this program need 3 csv files" >&2

else
	checkCsv $1 $2 $3
	if [ $? -eq 0 ];
	then

		echo "***************OSS1 Project1***************";
		echo "*          Student Id : 12191629          *";
		echo "*          Name : Yu Jae Woong            *";
		echo "*******************************************";
		menu
	fi;
 fi

