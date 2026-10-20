
#!/bin/bash

# ==============================================================================
# Script Name : 1_search_file_paths.sh
# Description : Search sequencing file paths from a master storage index
#               using sample IDs or text strings and selected file types.
#
# Author      : Ravi Prabhakar More
# Version     : 1.1
# Date        : 2026-10-20
#
# Usage:
#   bash 1_search_file_paths.sh <input_strings.txt> <filetype>
#
# Arguments:
#   1. input_strings.txt : Text file containing sample IDs (one per line)
#   2. filetype          : fastq | fastq.gz | bam | recalibrated.bam |
#                         vcf | vcf.gz | g.vcf.gz | all
#
# Example commands:
#   bash 1_search_file_paths.sh 2_input_strings.txt bam
#   bash 1_search_file_paths.sh 2_input_strings.txt recalibrated.bam
#   bash 1_search_file_paths.sh 2_input_strings.txt fastq
#   bash 1_search_file_paths.sh 2_input_strings.txt vcf.gz
#   bash 1_search_file_paths.sh 2_input_strings.txt g.vcf.gz
#   bash 1_search_file_paths.sh 2_input_strings.txt all
#
# Outputs:
#   <input_name>_<filetype>_matched.txt
#   <input_name>_<filetype>_not_matched.txt
#
# Notes:
#   - Case-insensitive, fixed-string search.
#   - Matches strings anywhere in the full file path.
#   - Searches an existing index; does not scan the filesystem.
#   - Does not verify that matched files still exist.
# ==============================================================================

set -euo pipefail

# -------- USAGE --------

usage() {
    cat <<EOF
Usage:
  bash $(basename "$0") <input_strings.txt> <filetype>

Supported file types:
  fastq
  fastq.gz
  bam
  recalibrated.bam
  vcf
  vcf.gz
  g.vcf.gz
  all

Examples:
  bash $(basename "$0") 2_input_strings.txt bam
  bash $(basename "$0") 2_input_strings.txt recalibrated.bam
  bash $(basename "$0") 2_input_strings.txt fastq
  bash $(basename "$0") 2_input_strings.txt vcf.gz
  bash $(basename "$0") 2_input_strings.txt all

EOF
}

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

# -------- INPUT ARGUMENTS --------

INPUT="$1"
FILETYPE="${2,,}"

# -------- PATH CONFIGURATION --------

BASE="/SAN/neuroscience/proj-863_vcf/ravimore/files_database/out/storage_files/full_paths"

MASTER="$BASE/ALL_STORAGE_MASTER_PATHS.txt"
OUTDIR="$BASE/search_results"

# -------- INPUT VALIDATION --------

if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input file not found: $INPUT" >&2
    exit 1
fi

if [[ ! -r "$INPUT" ]]; then
    echo "ERROR: Input file not readable: $INPUT" >&2
    exit 1
fi

if [[ ! -f "$MASTER" ]]; then
    echo "ERROR: Master index not found: $MASTER" >&2
    exit 1
fi

if [[ ! -r "$MASTER" ]]; then
    echo "ERROR: Master index not readable: $MASTER" >&2
    exit 1
fi

# -------- FILE TYPE FILTER --------

case "$FILETYPE" in

    fastq)
        REGEX='\.(fastq|fq)(\.gz)?$'
        ;;

    fastq.gz)
        REGEX='\.(fastq|fq)\.gz$'
        ;;

    bam)
        REGEX='\.bam$'
        ;;

    recalibrated.bam)
        REGEX='\.recalibrated\.bam$'
        ;;

    vcf)
        REGEX='\.vcf$'
        ;;

    vcf.gz)
        REGEX='\.vcf\.gz$'
        ;;

    g.vcf.gz)
        REGEX='\.g\.vcf\.gz$'
        ;;

    all)
        REGEX='.*'
        ;;

    *)
        echo "ERROR: Unsupported file type: $FILETYPE" >&2
        usage
        exit 1
        ;;
esac

# -------- OUTPUT DIRECTORY --------

mkdir -p "$OUTDIR"

NAME=$(basename "$INPUT")
NAME="${NAME%.*}"

MATCHED="$OUTDIR/${NAME}_${FILETYPE}_matched.txt"
NOT_MATCHED="$OUTDIR/${NAME}_${FILETYPE}_not_matched.txt"

# -------- TEMPORARY DIRECTORY --------

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

IDS="$TMPDIR/ids.txt"

# -------- CLEAN INPUT --------

sed 's/\r$//' "$INPUT" |
    sed '/^[[:space:]]*$/d' |
    LC_ALL=C sort -u > "$IDS"

TOTAL_IDS=$(wc -l < "$IDS")

if [[ "$TOTAL_IDS" -eq 0 ]]; then
    echo "ERROR: No valid search strings found in input." >&2
    exit 1
fi

# -------- SEARCH MASTER INDEX --------

echo "Searching master storage index..."

if [[ "$FILETYPE" == "all" ]]; then

    LC_ALL=C grep -iFf "$IDS" "$MASTER" \
        > "$MATCHED" || true

else

    LC_ALL=C grep -iFf "$IDS" "$MASTER" |
        LC_ALL=C grep -iE "$REGEX" \
        > "$MATCHED" || true

fi

# -------- IDENTIFY UNMATCHED STRINGS --------

: > "$NOT_MATCHED"

MATCHED_IDS=0
UNMATCHED_IDS=0

while IFS= read -r ID || [[ -n "$ID" ]]; do

    if LC_ALL=C grep -iFq -- "$ID" "$MATCHED"; then
        ((MATCHED_IDS+=1))
    else
        printf '%s\n' "$ID" >> "$NOT_MATCHED"
        ((UNMATCHED_IDS+=1))
    fi

done < "$IDS"

# -------- SUMMARY --------

TOTAL_PATHS=$(wc -l < "$MATCHED")

echo
echo "=================================================="
echo " Storage File Path Search - Version 1.1"
echo "=================================================="
echo "Input file          : $INPUT"
echo "File type           : $FILETYPE"
echo "Master index        : $MASTER"
echo "--------------------------------------------------"
echo "Total search IDs    : $TOTAL_IDS"
echo "Matched IDs         : $MATCHED_IDS"
echo "Unmatched IDs       : $UNMATCHED_IDS"
echo "Matched file paths  : $TOTAL_PATHS"
echo "--------------------------------------------------"
echo "Matched output      : $MATCHED"
echo "Not matched output  : $NOT_MATCHED"
echo "=================================================="
echo "Search completed successfully."
