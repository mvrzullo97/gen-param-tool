#!/bin/bash

# PATTERN PAN = <date>...<prg> + F
# PATTERN TARGA = AZ<prg>AZ

# usage menu
echo
echo "---------------------- Usage ----------------------"
echo -e "\n   bash $0\n\n    -n <number of triples to generate> \n    -f <first_plate_chars> (ex. AB) \n    -l <last_plate_chars> (ex. CD) \n"
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

function generate_PLATE
{
    PRG=$1
    plate_f=$2
    plate_l=$3
    pad_NUM="0"
    len_PLATE=7
    offset=$(expr $len_PLATE - ${#plate_f} - ${#PRG})
    while [ ${#plate_f} != $offset ] 
    do
        plate_f=$plate_f$pad_NUM
    done

    PLATE=$plate_f$PRG$plate_l
    echo ${PLATE}
}

function convert_PLATE_to_HEX 
{
    plate=$1
    pad_plate="07"
    hex_plate="$(printf '%s' "$plate" | xxd -p -u)"
    hex_plate=$pad_plate$hex_plate
    echo ${hex_plate}
}


while getopts n:f:l: flag
do
    	case "${flag}" in
		n) n=${OPTARG};;
        f) plate_f=${OPTARG};;
        l) plate_l=${OPTARG};;
		\?) echo -e "\nArgument error! \n"; exit 0 ;;
	esac
done

# check plate chars
if [[ "${plate_f}" =~ [^A-Z] ]] ; then
    echo "Param error: invalid first two chars of plate, use only [A-Z]"
    echo
	exit 0
fi

if [[ "${plate_l}" =~ [^A-Z] ]] ; then
    echo "Param error: invalid last two chars of plate, use only [A-Z]"
    echo
	exit 0
fi

# check plate's length
if [[ ${#plate_f} != 2 ]]; 
then
        echo "Param error: invalid plate format (only two first chars, ex. AB)"
        echo
	exit 0
fi

if [[ ${#plate_l} != 2 ]]; 
then
        echo "Param error: invalid plate format (only two first chars, ex. AB)"
        echo
	exit 0
fi

# vars delcaration
timestamp=$(date +"%Y%m%d")
LAST_PRG_USED=0 #if is the first run
MIN=5 #to do -> cambiare in seguito per get PRG from .txt
MAX=$(expr $MIN + $n - 1)
OUT_DIR="params_gen_OUT_DIR"
params_gen_FILE="params_generated.xml"

# create OUT_DIR if not exist
if ! [ -d $OUT_DIR ] ; then
	mkdir $OUT_DIR
	path_dir=$(realpath $OUT_DIR)
else
	path_OUT_dir=$(realpath $OUT_DIR)
fi



# get LAST_PRG_USED
if ! [ -f "$path_OUT_dir/$params_gen_FILE" ] ; then
        touch "$path_OUT_dir/$params_gen_FILE"
        chmod 0777 "$path_OUT_dir/$params_gen_FILE"
	else

        last_PRG="$(grep 'LAST_PRG_USED:' "$path_OUT_dir/$params_gen_FILE")"
        echo $last_PRG

        echo "file '$params_gen_FILE' found, the last prg used is x"
        echo
	fi


# tabula rasa of params_generated.txt
echo > "$path_OUT_dir/$params_gen_FILE"





list_PRG=( $(seq $MIN $MAX) )

elab_time=$(date +"%Y-%m-%d %H:%M:%S")

echo "EXECUTION_TIME : $elab_time"
echo -e "SCRIPT_EXECUTION_TIME: $elab_time\n" >> "$path_OUT_dir/$params_gen_FILE"
echo

for ((i=0; i<n; i++)) 
do

echo " --- tripla PAN-TARGA-HEX n° $(expr $i + 1) ---"
echo

PRG=${list_PRG[i]}

PAN=$(generate_PAN $PRG)
PLATE=$(generate_PLATE $PRG $plate_f $plate_l)
HEX_PLATE=$(convert_PLATE_to_HEX $PLATE)

echo "$PAN - $PLATE - $HEX_PLATE"
echo -e "$(expr $i + 1))$PAN - $PLATE - $HEX_PLATE \n" >> "$path_OUT_dir/$params_gen_FILE"

echo
done

last_PRG_used=$i
echo "LAST_PRG_USED: $PRG" >> "$path_OUT_dir/$params_gen_FILE"
echo
