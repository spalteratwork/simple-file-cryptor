#!/bin/bash

SECONDS=0
RED='\033[1;31m';
GREEN='\033[1;32m';
NC='\033[0m'; # No Color
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
NORMAL=$(tput sgr0)

#filename=$1
#doRecursive=0;

. _cryptor.lib

if [[ $# -eq 0 || "$filename" = "" || $doPrintHelp -eq 1 ]]; then
    printf "%b\n" "An input parameter specifying a file or directory is required for encryption.";
    printf "%b\n" "${style_bold}SYNOPSIS:${style_normal}";
    printf "%b\n" "\t./encrypt.sh [${style_underline}OPTION${style_normal}] ${style_underline}FILENAME${style_normal}";
    printf "%b\n\n" "\t./encrypt.sh [${style_underline}OPTION${style_normal}] ${style_underline}FOLDERNAME${style_normal}";
    printf "%b\n" "${style_bold}OPTIONS:${style_normal}";
    printf "%b\n" "\t${style_bold}-r, -R, --recursive${style_normal}";
    printf "%b\n\n" "\t\tencrypt directories and their contents recursively";
    exit 0;
fi

echo $doRecursive
exit 0;

printOk() {
    echo -e "[ ${GREEN}OK${NC} ]";
}

printErrorAndExit() {
    echo -e "[ ${RED}FAILED${NC} ]";
    echo -e "${RED}*** ABORT *** ${NC}- $1"
    exit 0;
}

encryptFile() {
    printf "Encrypting file %-165s " "$filename"

    chksum=$(sha1sum $filename | awk '{print $filename}')
    gpg --passphrase iAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40Pf --batch -c --output $filename.$chksum.gpg $filename 2>/dev/null
    if [ -f "$filename.$chksum.gpg" ]; then
        rm -f $filename
        printOk;
    else 
        printErrorAndExit "Encrypted file not found. After encryption the file $filename.$chksum.gpg is expected."; 
    fi
}

scanFolder () {
    for entry in "$filename"/*
    do
        if [[ -d "$entry" && $doRecursive -eq 1 ]]; then
            #echo "$entry is dir"
            scanFolder $entry
        elif [[ (-f "$entry" && ! "$entry" == *.gpg) ]]; then
            #echo "$entry is file"
            encryptFile $entry
        fi
    done
}


if [ -d "$filename" ]; then
    # Parameter überprüfen und Slash entfernen, falls vorhanden
    if [[ "$filename" == */ ]]; then
        myDir="${filename%/}"  # Entfernt das abschließende Slash
    else
        myDir="$filename"
    fi

    scanFolder $myDir

    echo
    echo "Directory $myDir successfully encrypted. Runtime: $((SECONDS / 60))m:$((SECONDS % 60))s.";
elif [[ (-f "$filename" && ! "$filename" == *.gpg) ]]; then
    encryptFile $filename

    echo
    echo "File $filename successfully encrypted. Runtime: $((SECONDS / 60))m:$((SECONDS % 60))s.";
else
    echo "File $filename not exists or is already a gpg file or not a directory.";
fi
