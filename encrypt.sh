#!/bin/bash

# Import cryptor-lib
. _cryptor.lib.sh

# Check if usage info needs to be displayed...
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

# Encrypt the given file (Param 1). The sha1 checksum is determined for the given file and this value is stored in the 
# file name of the encrypted file. This value is used for validation when decrypting the file.
encryptFile() {
    printf "Encrypting file %-165s " "$1"

    chksum=$(sha1sum $1 | awk '{print $1}')
    gpg --passphrase iAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40PfiAUQLlgwYvYpEkyoqQI96aH6AJ7V40Pf --batch -c --output $1.$chksum.gpg $1 2>/dev/null
    if [ -f "$1.$chksum.gpg" ]; then
        chmod --reference="$1" -- "$1.$chksum.gpg"; # Keep file permission
        touch -r "$1" "$1.$chksum.gpg"; # keep file attributes
        rm -f $1
        printOk;
    else 
        printErrorAndExit "Encrypted file not found. After encryption the file $1.$chksum.gpg is expected."; 
    fi
}

# Encrypt the specified file or browse the specified directory for encryptable files.
scanFolder () {
    for entry in "$1"/*
    do
        if [[ -d "$entry" && $doRecursive -eq 1 ]]; then
            # Param is a directory, so dig deeper and look for more files that can be encrypted.
            scanFolder $entry
        elif [[ (-f "$entry" && ! "$entry" == *.gpg) ]]; then
            # Param is a file, so start encryption
            encryptFile $entry
        fi
    done
}

# Start enryption
if [ -d "$filename" ]; then
    scanFolder $filename;

    printf "\n%s\n" "Directory $filename successfully encrypted. Runtime: $((SECONDS / 60))m:$((SECONDS % 60))s.";
elif [[ (-f "$filename" && ! "$filename" == *.gpg) ]]; then
    encryptFile $filename

    printf "\n%s\n" "File $filename successfully encrypted. Runtime: $((SECONDS / 60))m:$((SECONDS % 60))s.";
else
    printf "%s\n" "File $filename not exists or is already a gpg file or not a directory.";
fi
