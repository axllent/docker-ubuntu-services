#!/usr/bin/env bash
## Modified version of https://github.com/yurkeen/example-bash-logrotate/blob/master/logrotate.sh

function print_help() {
help="
Usage: $0 <options>
Available options:
  --name=\"<search pattern>\"
        Names for the files to rotate. Could be '*.log' or a regular expression.
  --source=\"source_dir\"
        Source directory where to look for files. If not specified, current directory is used.
  --destination=\"[destination dir]\"
        Destination directory to move files to. If not specified, files are compressed within the directory specified with '--source'.
  --keep=[days]
        Number of days to keep files. Files older days than this number will be deleted. Default 5.
  --min=[kb]
        Minimum size to rotate logs. Smaller files will be ignored.
  --check
        If set, do not perform actual actions, rather show what would be done.
"

echo "$help"
}

# Exit and print help when no args specified
[ $# -eq 0 ] && { echo "No arguments supplied."; print_help;  exit 1; }

# Reading arguments here
for i in "$@"
do
    case $i in
        -h|--help)
        print_help
        ;;
        --name=*)
        NAME_PATTERN="${i#*=}"
        shift # past argument=value
        ;;
        --source=*)
        SRC_DIR="${i#*=}"
        shift # past argument=value
        ;;
        --destination=*)
        DST_DIR="${i#*=}"
        shift # past argument=value
        ;;
        --keep=*)
        KEEP="${i#*=}"
        shift # past argument=value
        ;;
        --min=*)
        MIN="${i#*=}"
        shift # past argument=value
        ;;
        --check)
        CHECK_FLAG="True"
        shift # past argument=value
        ;;
        *)
                # unknown option
                printf "Unknown option %s\n" "$i"
        ;;
    esac
done

[ -z "$SRC_DIR"  ] && { echo "Source directory ( --source=<source_dir> ) is mandatory."; exit 1; }

# Strip trailing slash from the dir
SRC_DIR=${SRC_DIR%/}

# Set DST_DIR the same as SRC_DIR if not set as a pramaeter.
DST_DIR=${DST_DIR:-$SRC_DIR}

KEEP_FILES=${KEEP:-5}

# Add name matching if --name is set.
OPT_NAME=${NAME_PATTERN:+"-name $NAME_PATTERN"}

# Add name matching if --name is set.
MIN_SIZE=${MIN:+"-size +${MIN}k"}

for filepath in $(find "$SRC_DIR" -maxdepth 1 -type f $OPT_NAME $MIN_SIZE)
do
    FROMHERE=KEEP_FILES
    for ((i=FROMHERE; i>=1; i--))
    do
        if [ -f "${DST_DIR}/${filepath##*/}.$i.gz" ]; then
            if [ "$i" -eq "$KEEP_FILES" ]; then
                if [ -z "$CHECK_FLAG" ]; then
                    rm -f "${DST_DIR}/${filepath##*/}.$i.gz"
                else
                    echo "rm -f \"${DST_DIR}/${filepath##*/}.$i.gz\""
                fi
            else
                NEXT=$((i+1))
                if [ -z "$CHECK_FLAG" ]; then
                    mv "${DST_DIR}/${filepath##*/}.$i.gz" "${DST_DIR}/${filepath##*/}.$NEXT.gz"
                else
                    echo "mv \"${DST_DIR}/${filepath##*/}.$i.gz\" \"${DST_DIR}/${filepath##*/}.$NEXT.gz\""
                fi
            fi
        fi
    done
    if [ -z "$CHECK_FLAG" ]; then
        gzip --best -c "$filepath" > "${DST_DIR}/${filepath##*/}.1.gz" && \
        cat /dev/null > "$filepath"
    else
        echo "gzip --best -c \"$filepath\" > \"${DST_DIR}/${filepath##*/}.1.gz\" && cat /dev/null > \"$filepath\""
    fi
done
