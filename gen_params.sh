#!/bin/bash

# PATTERN PAN = <date>...<prg> + F
# PATTERN TARGA = AZ<prg>AZ

# usage menu
echo
echo "---------------------- Usage ----------------------"
echo -e "\n   bash $0\n\n    -n <number of iterations> \n -t <plate_pattern (ex. AB)> \n"
echo


# functions
function generate_PAN 
{
    prg=$1
    pad_NUM="0"
    pad_F="F"
    pad_PRG_F=$1$pad_F
    len_PAN=19
    str=$timestamp
    offset=$(expr $len_PAN - ${#pad_PRG_F})

    while [ ${#str} != $offset ] 
    do
        str=$str$pad_NUM
    done
    
    str=$str$pad_NUM$pad_PRG_F

    echo ${str}
}


while getopts n: flag
do
    	case "${flag}" in
		n) n=${OPTARG};;
		\?) echo -e "\nArgument error! \n"; exit 0 ;;
	esac
done

# vars delcaration
timestamp=$(date +"%Y%m%d")
MIN=5 #to do -> cambiare in seguito per get PRG from .txt
MAX=$(expr $MIN + $n - 1)

list_PRG=( $(seq $MIN $MAX) )

echo " ----- Generazione PAN ----- "
echo

for ((i=0; i<n; i++)) 
do
    
PAN=$(generate_PAN ${list_PRG[i]})
echo "PAN $i = $PAN"


done
