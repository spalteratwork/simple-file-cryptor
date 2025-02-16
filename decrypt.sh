#!/bin/bash

# Import cryptor-lib
. _cryptor.lib.sh

# Check if usage info needs to be displayed...
if [[ $# -eq 0 || "$filename" = "" || $doPrintHelp -eq 1 ]]; then
    printf "%b\n" "An input parameter specifying a file or directory is required for encryption.";
    printf "%b\n" "${style_bold}SYNOPSIS:${style_normal}";
    printf "%b\n" "\t./decrypt.sh [${style_underline}OPTION${style_normal}] ${style_underline}FILENAME${style_normal}";
    printf "%b\n\n" "\t./decrypt.sh [${style_underline}OPTION${style_normal}] ${style_underline}FOLDERNAME${style_normal}";
    printf "%b\n" "${style_bold}OPTIONS:${style_normal}";
    printf "%b\n" "\t${style_bold}-r, -R, --recursive${style_normal}";
    printf "%b\n\n" "\t\tdecrypt directories and their contents recursively";
    exit 0;
fi

# Decrypt the given file (Param 1). With the encryption, the sha1 checksum was stored in the filename. This value is 
# determined here and then compared with the sha checksum of the decrypted file. If these are identical, the decryption 
# was successful and the encrypted file can be deleted.
decryptFile() {
    printf "Decrypting file %-165s " "$1"

    filename_size=${#1} 
    if [[ "$1" =~ ^.*\.[a-z0-9]{40}\.gpg$ ]]; then
        myFilename=${1:0:$filename_size-45};
        #extension=${1:$filename_size-3:3};
        chksum=${1:$filename_size-44:40};

        gpg --passphrase iAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40Pf --batch -d --output $myFilename $1 2>/dev/null
        chksum_new=$(sha1sum $myFilename | awk '{print $1}')
        if [ "$chksum" = "$chksum_new" ]; then
            chmod --reference="$1" -- "$myFilename"; # Keep file permission
            touch -r "$1" "$myFilename"; # keep file attributes        
            rm -f $1
            printOk;
        else
            printErrorAndExit "Checksum invalid! Expected checksum is $chksum. Decrypted file has checksum $chksum_new.";
        fi
    else
        printErrorAndExit "Invalid filename format. Expected format: [name.sha1sum.gpg]";
    fi
}

# Decrypt the specified file or browse the specified directory for decryptable files.
scanFolder () {
    for entry in "$1"/*
    do
        if [[ -d "$entry" && $doRecursive -eq 1 ]]; then
            scanFolder $entry
        elif [[ (-f "$entry" && "$entry" == *.gpg) ]]; then
            decryptFile $entry
        fi
    done
}

# Start decryption
if [ -d "$filename" ]; then
    scanFolder $filename;

    printf "\n%s\n" "Directory $filename successfully decrypted. Runtime: $((stat_seconds / 60))m:$((stat_seconds % 60))s.";
elif [[ (-f "$1" && "$1" == *.gpg) ]]; then
    decryptFile $1

    printf "\n%s\n" "File $filename successfully decrypted. Runtime: $((stat_seconds / 60))m:$((stat_seconds % 60))s.";
else
    printf "%s\n" "File $1 not exists or is neither a gpg file nor a directory.";
fi
