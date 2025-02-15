#!/bin/bash

SECONDS=0
RED='\033[1;31m';
GREEN='\033[1;32m';
NC='\033[0m'; # No Color
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
NORMAL=$(tput sgr0)
doRecursive=1;

if [ $# -eq 0 ]; then
    echo "An input parameter specifying a file or directory is required.";
    echo "${BOLD}SYNOPSIS:${NORMAL}";
    echo -e "\t./decrypt.sh ${UNDERLINE}filename${NORMAL}";
    echo -e "\t./decrypt.sh ${UNDERLINE}foldername${NORMAL}";
    echo 
    exit;
fi

while getopts ":r:" arg; do
  case $arg in
    r) # Specify p value.
      doRecursive=1;
      ;;
  esac
done

printOk() {
    echo -e "[ ${GREEN}OK${NC} ]";
}

printErrorAndExit() {
    echo -e "[ ${RED}FAILED${NC} ]";
    echo -e "${RED}*** ABORT *** ${NC}- $1"
    exit 0;
}

decryptFile() {
    printf "Decrypting file %-165s " "$1"

    filename_size=${#1} 
    #if [ $filename_size -gt 46 ]; then
    if [[ "$1" =~ ^.*\.[a-z0-9]{40}\.gpg$ ]]; then
        filename=${1:0:$filename_size-45};
        extension=${1:$filename_size-3:3};
        chksum=${1:$filename_size-44:40};

        gpg --passphrase iAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40Pf --batch -d --output $filename $1 2>/dev/null
        chksum_new=$(sha1sum $filename | awk '{print $1}')
        if [ "$chksum" = "$chksum_new" ]; then
            rm -f $1
            printOk;
        else
            printErrorAndExit "Checksum invalid! Expected checksum is $chksum. Decrypted file has checksum $chksum_new.";
        fi
    else
        printErrorAndExit "Invalid filename format. Expected format: [name.sha1sum.gpg]";
    fi
}

scanFolder () {
    for entry in "$1"/*
    do
        if [[ -d "$entry" && $doRecursive -eq 1 ]]; then
            #echo "$entry is dir"
            scanFolder $entry
        elif [[ (-f "$entry" && "$entry" == *.gpg) ]]; then
            #echo "$entry is file"
            decryptFile $entry
        fi
    done
}

if [ -d "$1" ]; then
    # Parameter überprüfen und Slash entfernen, falls vorhanden
    if [[ "$1" == */ ]]; then
        myDir="${1%/}"  # Entfernt das abschließende Slash
    else
        myDir="$1"
    fi

    scanFolder $myDir

    echo
    echo "Directory $myDir successfully decrypted. Runtime: $((SECONDS / 60))m:$((SECONDS % 60))s.";
elif [[ (-f "$1" && "$1" == *.gpg) ]]; then
    decryptFile $1

    echo
    echo "File $1 successfully decrypted. Runtime: $((SECONDS / 60))m:$((SECONDS % 60))s.";
else
    echo "File $1 not exists or is neither a gpg file nor a directory.";
fi
