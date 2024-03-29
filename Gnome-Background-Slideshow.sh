command=$0
subcommand=$1

_help() {
	echo "Subcommands":
	echo "Start"
	echo "Stop"
}

case $subcommand in
    "" | help)
        _help
        ;;
    
    *)
        shift
        ${subcommand}.sh $@
        if ! [ $? = 0 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$command --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac
