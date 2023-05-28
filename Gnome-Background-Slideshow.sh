#!/bin/bash

_help() {
	GREEN='\033[1;32m'
	LIGHT_BLUE='\033[1;36m'
	NC='\033[0m'
	
	t1="\t"
	t2="\t\t"
	t4="\t\t\t\t"

	echo -e "${GREEN}NAME${NC}"
	echo -e "${t1}Gnome-Background-Slideshow - Program to turn your gnome wallpapers into a slideshow"

	echo -ne "\n"

	echo -e "${GREEN}USAGE${NC}"
	echo -e "${t1}${GREEN}Gnome-Background-Slideshow${NC} [${LIGHT_BLUE}OPTIONS${NC}]"

	echo -ne "\n"

	echo -e "${GREEN}OPTIONS${NC}"
	
	echo -e "${t1}${GREEN}-c, --cycle${NC}${t2}Cycle the wallpapers after the end is reached."
	echo -e "${t4}Enable to make the slideshow neverending."

	echo -ne "\n"
	
	echo -e "${t1}${GREEN}-d, --delay${NC}${t2}How long each wallpaper should stay up in seconds."
	echo -e "${t4}(Default: 60) - For some reason gnome-shell usage has been known"
	echo -e "${t4}to spike to 100% rendering the screen frozen,"
	echo -e "${t4}if the delay is not long enough."
	echo -e "${t4}Recommended value of at least 10 seconds."

	echo -ne "\n"
	
	echo -e "${t1}${GREEN}-h, --help${NC}${t2}Show this help message."
	
	echo -ne "\n"
	
	echo -e "${t1}${GREEN}-k, --kill${NC}${t2}Kill any previous instances of this program."
	
	echo -ne "\n"
	
	echo -e "${t1}${GREEN}-p, --path${NC}${t2}Path to directory containing your wallpapers."
	echo -e "${t4}(Default: \$HOME/Pictures/wallpapers)"

	echo -ne "\n"

	echo -e "${t1}${GREEN}-r, --randomize${NC}${t2}Randomize the order of wallpapers shown:"
	echo -e "${t4}(Default: alphabetically)"

	echo -ne "\n"

	echo -e "${t1}${GREEN}-v, --verbose${NC}${t2}Enable debug print statements."
}

# Call getopt to validate the provided input. 
options=$(getopt --options "c,d:,h,k,p:,r,v" --longoptions "cycle,delay:,help,kill,path:,randomize,verbose" -- "$@")

# Default values
CYCLE=false
DELAY=60
_PATH="$HOME/Pictures/Wallpapers"
RANDOMIZE=false
VERBOSE=false

eval set -- "$options"
while true; do
    case "$1" in
    	"-c" | "--cycle")
		    CYCLE=true
		    ;;
		    
		"-d" | "--delay")
		    shift;
			if ! [[ "$1" =~ ^[0-9]+$ ]] ; then
				echo "Invalid arguement for delay: $1 is not a positive number."
				exit 1
			fi
		    DELAY=$1
		    ;;
		    
		"-h" | "--help")
			_help
			exit 0
		    ;;
		    
		"-k" | "--kill")
		    kill $(pgrep -f "Gnome-Background-Slideshow.sh" | grep -v $$) 2> /dev/null
		    ;;
		    
		"-p" | "--path")
		    shift;
			if [ ! -d "$1" ]; then
				echo "Invalid arguement for path: $1 is not a directory."
				exit 1
			fi
			_PATH=$1
		    ;;
		    
		"-r" | "--randomize")
		    RANDOMIZE=true
		    ;;
		    
		"-v" | "--verbose")
		    VERBOSE=true
		    ;;

		--) 
			shift; 
			break 
			;;
    esac
    shift
done

if [ "$VERBOSE" = true ] ; then
	echo "CYCLE: $CYCLE"
	echo "DELAY: $DELAY"
	echo "PATH: $_PATH"
	echo "RANDOMIZE: $RANDOMIZE"
fi

shopt -s nullglob
wallpapers=("$_PATH"/*)

# if randomize is set shuffle the array else sort array alphabetically and case insensitive
if [ "$RANDOMIZE" = true ] ; then
	mapfile -t wallpapers< <(shuf -e "${wallpapers[@]}")
else
	IFS=$'\n' wallpapers=($(sort -f <<<"${wallpapers[*]}")); unset IFS
fi

if [ "$VERBOSE" = true ] ; then
	echo "wallpapers (${#wallpapers[@]}):"
	for (( i=0; i<${#wallpapers[@]}; i++ )); do
		wallpaper="$(basename "${wallpapers[$i]}")"
		if [ $i -ne $((${#wallpapers[@]}-1)) ]; then
			echo -n "$wallpaper, "
		else
			echo "$wallpaper"
			echo -ne "\n"
		fi
	done
fi

while true; do
	for wallpaper in "${wallpapers[@]}"; do
		if [ "$VERBOSE" = true ] ; then
			echo "Switching to: $(basename "$wallpaper")"
		fi
		gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
		gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper"
		sleep "$DELAY"
	done
	if [ "$CYCLE" = false ] ; then
		break
	fi
done

exit 0;
