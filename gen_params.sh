#!/bin/bash
# PATTERN PAN = <date>...<prg> + F
# PATTERN TARGA = AZ<prg>AZ

# usage menu
echo
echo "---------------------- Usage ----------------------"
echo -e "\n   bash $0\n\n    -n < number of triples to generate > \n    -p < plate number chars > (ex. ABCD) \n    -o < optional, plate number prg >"
echo

# to do  param opzionale in cui vado ad inserire io la partenza della targa 

while getopts n:p:o: flag
do
    	case "${flag}" in
		n) n=${OPTARG};;
        p) PLATE_NUMBER=${OPTARG};;
        o) PRG_PLATE=${OPTARG};;
		\?) echo -e "\n Argument error! \n"; exit 0 ;;
	esac
done

plate_f=${PLATE_NUMBER:0:2}
plate_l=${PLATE_NUMBER:2:2}

# check plate chars
if [[ "${plate_f}" =~ [^A-Z] ]] ; then
    echo -e "Param error: invalid first two chars of plate, use only [A-Z] \n"
	exit 0
fi

if [[ "${plate_l}" =~ [^A-Z] ]] ; then
    echo -e "Param error: invalid last two chars of plate, use only [A-Z] \n"
	exit 0
fi

# check plate's length
if [ ${#PLATE_NUMBER} != 4 ] ; then 
    echo -e "Param error: length of PLATE_NUMBER must be 4 \n"
    exit 0
fi

# vars delcaration
current_timestamp=$(date +"%Y%m%d")
OUT_DIR="OUT_DIR"
params_gen_FILE="params_gen.xml"
upper_bound=$(expr $PRG_PLATE + $n)

if ! [ $upper_bound -lt 999 ] ; then 
    echo -e "Param error: progressive plate number out of bounds (0 < PLATE_NUMBER < 999 - #iterations) \n"
    exit 0
fi

# create OUT_DIR if not exist
if ! [ -d $OUT_DIR ] ; then
	mkdir $OUT_DIR
	path_OUT_dir=$(realpath $OUT_DIR)
    echo -e "create '$OUT_DIR' at path: '$path_OUT_dir' \n"
    chmod 0777 "$path_OUT_dir"
else
	path_OUT_dir=$(realpath $OUT_DIR)
fi


# functions
function generate_PAN 
{
    PRG=$1
    pad_NUM="0"
    pad_F="F"
    pad_PRG_F=$PRG$pad_F
    len_PAN=19
    str=$current_timestamp
    offset=$(expr $len_PAN - ${#pad_PRG_F})

    while [ ${#str} != $offset ] 
    do
        str=$str$pad_NUM
    done
    
    str=$str$pad_NUM$pad_PRG_F
    echo ${str}
}

function generate_PLATE_NUMBER
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



# get LAST_PRG_USED
if ! [ -f "$path_OUT_dir/$params_gen_FILE" ] ; then
        touch "$path_OUT_dir/$params_gen_FILE"
        chmod 0777 "$path_OUT_dir/$params_gen_FILE"
        last_PRG_value=0 #if it's the first run
	else  
        # get and clean old timestamp from file
        old_timestamp_line="$(grep 'SCRIPT_EXECUTION_TIME:' "$path_OUT_dir/$params_gen_FILE")"
        old_timestamp_value=${old_timestamp_line#*:}
        old_timestamp_value="${old_timestamp_value: 1:10}"
        old_timestamp_value="${old_timestamp_value//-}"
        
        if  [ $old_timestamp_value == $current_timestamp ] ; then
            # get LAST PRG USED before tabula rasa
            line_last_PRG="$(grep 'LAST_PRG_USED:' "$path_OUT_dir/$params_gen_FILE")"
            last_PRG_value=${line_last_PRG#*:}
            echo -e "file '$params_gen_FILE' found, the last prg used is '$last_PRG_value' \n"
        else
            last_PRG_value=0
        fi 
	fi

# tabula rasa of params_gen.xml
echo > "$path_OUT_dir/$params_gen_FILE"

if [ $PRG_PLATE != '' ] ; then
    MIN=$PRG_PLATE
    MAX=$(expr $MIN + $n)
    list_PRG=( $(seq $MIN $MAX) )
else 
    MIN=$(expr $last_PRG_value + 1)
    MAX=$(expr $MIN + $n - 1)
    list_PRG=( $(seq $MIN $MAX) )
fi

elab_time=$(date +"%Y-%m-%d %H:%M:%S")

echo -e "script_execution_time: $elab_time \n"
echo -e "using PRG from $MIN to $MAX \n"

echo -e "SCRIPT_EXECUTION_TIME: $elab_time \n" >> "$path_OUT_dir/$params_gen_FILE"
echo -e "using PRG from $MIN to $MAX \n" >> "$path_OUT_dir/$params_gen_FILE"


for ((i=0; i<n; i++)) 
do

echo -e " --- PAN-TARGA-HEX triple n° $(expr $i + 1) --- OK \n"

PRG=${list_PRG[i]}

PAN=$(generate_PAN $PRG)
PLATE=$(generate_PLATE_NUMBER $PRG $plate_f $plate_l)
HEX_PLATE=$(convert_PLATE_to_HEX $PLATE)

#echo "$PAN - $PLATE - $HEX_PLATE"
echo -e "$(expr $i + 1)) $PAN - $PLATE - $HEX_PLATE \n" >> "$path_OUT_dir/$params_gen_FILE"

done

echo -e "triple generation COMPLETED, check the file '$params_gen_FILE' at path: '$path_OUT_dir/$params_gen_FILE' \n"
echo "LAST_PRG_USED: $PRG" >> "$path_OUT_dir/$params_gen_FILE"
echo
