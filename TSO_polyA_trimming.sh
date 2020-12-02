#!/bin/bash

# Define adapter sequence
TSO=XAAGCAGTGGTATCAACGCAGAGTACATGGG

# Get script name
SCRIPT=$(basename "$0")

FASTQ=''
while (( "$#" )); do
  case "$1" in
    -l|--homopolymer-length)
      LENGTH=$2
      shift 2
      ;;
    -o|--output)
      OUTPUT=$2
      shift 2
      ;;
    -e|--error-tolerance)
      ETOL=$2
      shift 2
      ;;
    --overlap)
      OVERLAP=$2
      shift 2
      ;;
    -h|--help)
cat << EOF
$SCRIPT [-h] [-l -o -e --overlap n] 

   This script takes a FASTQ formatted file as input and uses 
   cutadapt to scan the 5' end for the TSO sequence: $TSO 
   and the 3' end for polyA homopolymers. 

   If any of these sequences are found, they are trimmed of and the 
   remaining sequences are returned. Truncated matches are also 
   detected and removed (as long as the match is at least long as 
   the minimum allowed overlap), with the restriction that it has 
   to be located at the 5' end. The same is true for polyA homopolymers 
   but for the 3' end. 

   For example, if the truncated TSO sequence AGTACATGGG is found at 
   the 5' end, this will be removed but not if it's found in the middle 
   of the read sequence.

   Cutadapt allows for error tolerant matching, so the matches can 
   contain a few error depending on the error tolerance that is 
   specified. If you for example select an error tolerance of 0.1, 
   the number of allowed error in a sequence of length N will be 
   calculated as N*0.1 rounded to the nearest lower integer. 

   Below is an example of what this would mean for the 30bp TSO. 

   If the error tolerance is set to 0.1:

   0-9 bp = 0 errors allowed
   10-19 bp = 1 error allowed
   20-29 bp = 2 errors allowed
   30 bp = 3 errors allowed

   References:
   Non-internal 5' adapter - https://cutadapt.readthedocs.io/en/stable/guide.html#non-internal
   Regular 3' adapters - https://cutadapt.readthedocs.io/en/stable/guide.html#regular-3-adapters
   Error tolerance - https://cutadapt.readthedocs.io/en/stable/guide.html#error-tolerance
   Miminum overlap - https://cutadapt.readthedocs.io/en/stable/guide.html#minimum-overlap-reducing-random-matches

   options:
    -h|--help  Print help messages
    -l|--homopolymer-length  set the minimum homopolymer length (default: 10)
    -o|--output name of output file
    -e|--error-tolerance set the error tolerance for cutadapt (default: 0.1)
    --overlap set the minimum overlap for cutadapt (default: 5)

EOF
      exit 1
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      if [[ $FASTQ ]]; then
            echo "More than 1 input file provided" >&2
	    exit 1
      fi
      FASTQ=$1
      shift
      ;;
  esac
done

# Find file extension
EXTENSION=`echo $(basename $FASTQ) | cut -d'.' -f2,3`

if [[ ! $LENGTH ]]; then
	POLA=AAAAAAAAAA; else
	POLA="$(printf '%*s' $LENGTH "" | tr ' ' 'A')"
fi
if [[ ! $FASTQ ]]; then
	echo "No fastq file supplied"
	exit 1
fi
if ! [[ $EXTENSION == "fastq" || $EXTENSION == "fastq.gz" ]]; then
	echo "Input file has to be either a fastq file or fastq.gz" >&2
	exit 1
fi 
if [[ ! $ETOL ]]; then
	ETOL=0.1
fi
if [[ ! $OVERLAP ]]; then
	OVERLAP=5
fi
if [[ ! $OUTPUT ]]; then
	OUTPUT=${FASTQ%".$EXTENSION"}_TSO_and_polyA_filtered.$EXTENSION
fi

cutadapt --cores=0 \
	-g ""$TSO";max_error_rate="$ETOL"" \
	-a ""$POLA";max_error_rate=0" \
	--overlap $OVERLAP \
	-o $OUTPUT \
	-n 2 \
$FASTQ
