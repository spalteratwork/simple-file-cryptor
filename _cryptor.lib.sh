# Base functions and global variables

##### Functions

printOk() {
    printf "%b\n" "[ ${color_green}OK${color_default} ]";
}

printErrorAndExit() {
    if [ $# -eq 1 ]; then
        printf "%b\n" "[ ${color_red}FAILED${color_default} ]";
    fi
    printf "%b\n" "${color_red}*** ABORT *** ${color_default}- $1";

    exit 0;
}

getOptionsFromCommandLine() {
    for var in "$@"
    do
        if [[ "$var" == "-r" || "$var" == "-R" || "$var" == "--recursive" ]]; then
            doRecursive=1;
        elif [ "$var" == "-h" ]; then
            doPrintHelp=1;
        elif [[ $var == -* ]]; then
            printErrorAndExit "Invalid argument: $var. Use -h to display usage information." 0;
        else
            filename="$var";

            # Check if param is a folder and remove a trailing slash
            if [ -d "$filename" ]; then
                if [[ "$filename" == */ ]]; then
                    filename="${filename%/}"  # remove a trailing slash
                fi
            fi
        fi
    done
}



##### variables

# work vars
filename=;
doRecursive=0;
doPrintHelp=0;

# Colors
color_default='\033[0m';
color_red='\033[1;31m';
color_green='\033[1;32m';

# Font styles
style_bold=$(tput bold);
style_underline=$(tput smul);
style_normal=$(tput sgr0);


##### Initial state
getOptionsFromCommandLine "$@";

