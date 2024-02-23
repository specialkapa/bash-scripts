#!/bin/bash

# Dependencies:
# - date: For generating timestamps.
# - grep: For colorizing output.
# - tail, cat: For displaying log contents.
# - cut: For parsing log entries.
# - gum For a smooth interactive experience

LOG_FILE="$HOME/my-repos/bash-scripts/did.log"

# @description Display help message on usage
# @example
#   did usage
usage() {
    echo "Usage: "
    echo "  did log [message]         Log a new activity with a timestamp."
    echo "  did show [options]        Show log entries with timestamps in purple and messages in white."
    echo "  did purge                 Delete the log file after confirmation."
    echo "Options for show:"
    echo "  -n [number]               Show the last [number] of entries."
}

# @description Initialise log if it does not exist. Will not be used by the user directly
# @example
#   initialise_log
initialize_log() {
    if [ ! -f "$LOG_FILE" ]; then
		gum confirm "Log file does not exist. Would you like to create it at $LOG_FILE?" && answer="y"
        if [ "$answer" = "y" ]; then
			mkdir "$HOME/.cache/did/"
            touch "$LOG_FILE"
            echo "Log file created at $LOG_FILE."
        else
            echo "Log file not created. Exiting."
            exit 1
        fi
    fi
}

# @description Add an entry in the log
# @arg $1 string Activity to log
# @example
#   log_activity "today I wrote the did.sh script"
log_activity() {
    # Check if a message was provided
    if [ "$#" -eq 0 ]; then
        echo "Error: No message provided for logging."
        exit 1
    fi

    # Get current date and time
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # Append the message to the log file
    echo "$TIMESTAMP: $*" >> "$LOG_FILE"
}

# @description Print the log in the shell
# @arg $1 int The last n number of lines to show
# @example
#   show_log
#   show_log 20
show_log() {
    local count=0

    # Parse options for 'show'
    while getopts ":n:" opt; do
        case $opt in
            n) count=$OPTARG ;;
            \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
        esac
    done

    if [ $count -gt 0 ]; then
        tail -n $count "$LOG_FILE" | while IFS= read -r line; do
            # Correctly split the timestamp and the message
            local timestamp=$(echo "$line" | cut -d' ' -f1-2)
            local message=$(echo "$line" | cut -d' ' -f3-)
            # Apply color to the timestamp and message separately
            echo -e "\033[95m$timestamp\033[0m \033[97m$message\033[0m"
        done
    else
        cat "$LOG_FILE" | while IFS= read -r line; do
            local timestamp=$(echo "$line" | cut -d' ' -f1-2)
            local message=$(echo "$line" | cut -d' ' -f3-)
            echo -e "\033[95m$timestamp\033[0m \033[97m$message\033[0m"
        done
    fi
}

# @description Delete existing log
# @example
#   purge_log
purge_log() {
	gum confirm "Are you sure you want to delete the log file at $LOG_FILE?" && answer="y"
    if [[ "$answer" = "y" ]]; then
        rm -f "$LOG_FILE"
        echo "Log file deleted."
    else
        echo "Log deletion cancelled."
    fi
}

initialize_log

# Main script logic
case $1 in
    log) shift; log_activity "$@" ;;
    show) shift; show_log "$@" ;;
	purge) purge_log ;;
    *) usage ;;
esac
