#!/bin/bash
SCRIPT_NAME=$0

SIZE_KB=1024
WAIT=300
INTERVAL=0

errorExit () {
    echo -e "\nERROR: $1\n"
    exit 1
}

usage () {
    cat << END_USAGE

${SCRIPT_NAME} - Create a process to hold RAM memory for a given time

Usage: ${SCRIPT_NAME} <options>

-k | --kb                       : Size of memory to hold in KB (default $SIZE_KB KB)
-w | --wait                     : Keep running when done (default $WAIT seconds)
-i | --interval                 : Interval between each memory increase (default $INTERVAL)
-h | --help                     : Show this usage

Examples:
========
# Create a 20 MB memory process and wait 10 minutes
$ ${SCRIPT_NAME} --kb 20480

END_USAGE

    exit 1
}

# Process command line options. See usage above for supported options
processOptions () {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -k | --kb)
                SIZE_KB="$2"
                shift 2
            ;;
            -w | --wait)
                WAIT="$2"
                shift 2
            ;;
            -i | --interval)
                INTERVAL="$2"
                shift 2
            ;;
            -h | --help)
                usage
                exit 0
            ;;
            *)
                usage
            ;;
        esac
    done
}

main () {
    processOptions "$@"
    local str=
    local memory=

    echo "My PID is $$"
    echo -n "## Base RSS memory: "
    grep VmRSS /proc/$$/status | awk '{print $2}'
    echo

    # Generating variables
    echo -n "> Creating ${SIZE_KB} 1KB objects... "
    for i in $(seq 0 "${SIZE_KB}"); do
        # Create a 1KB string
	    str=$(seq -w -s '' 0 340)
        eval array"$i"="${str}"
        [[ ${INTERVAL} -eq 0 ]] || sleep "${INTERVAL}"
    done

    echo "Done"

    echo -n "## Current RSS memory: "
    grep VmRSS /proc/$$/status | awk '{print $2}'

    echo "Sleeping for ${WAIT} seconds"

    sleep "${WAIT}"
}

main "$@"
