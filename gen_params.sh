#!/bin/bash

# PATTERN PAN = <date>...<prg> + F
# PATTERN TARGA = AZ<prg>AZ

# usage menu
echo
echo "---------------------- Usage ----------------------"
echo -e "\n   bash $0\n\n    -n <number of iterations> \n    -p <plate_pattern (only two first chars, ex. AB)> \n"
echo


# functions
function generate_PAN 
{
    PRG=$1
    pad_NUM="0"
    pad_F="F"
    pad_PRG_F=$PRG$pad_F
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

function generate_TARGA 
{
    PRG=$1
    PLATE=$2
    pad_NUM="0"
    len_PLATE=7
    offset=$(expr $len_PLATE - ${#PLATE} - ${#PRG})
    while [ ${#PLATE} != $offset ] 
    do
        PLATE=$PLATE$pad_NUM
    done

    PLATE=$PLATE$PRG$plate
    echo ${PLATE}
}

function convert_TARGA_to_HEX 
{
    plate=$1
    pad_plate="07"
    hex_plate="$(printf '%s' "$plate" | xxd -p -u)"
    hex_plate=$pad_plate$hex_plate
    echo ${hex_plate}
}


while getopts n:p: flag
do
    	case "${flag}" in
		n) n=${OPTARG};;
        p) plate=${OPTARG};;
		\?) echo -e "\nArgument error! \n"; exit 0 ;;
	esac
done

# vars delcaration
timestamp=$(date +"%Y%m%d")
MIN=5 #to do -> cambiare in seguito per get PRG from .txt
MAX=$(expr $MIN + $n - 1)

list_PRG=( $(seq $MIN $MAX) )

for ((i=0; i<n; i++)) 
do

echo "coppia PAN/TARGA n° $i"
echo

PRG=${list_PRG[i]}

PAN=$(generate_PAN $PRG)
echo $PAN

TARGA=$(generate_TARGA $PRG $plate)
echo $TARGA

HEX_TARGA=$(convert_TARGA_to_HEX $TARGA)
echo $HEX_TARGA
echo

done
