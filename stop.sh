#!/bin/bash

n=$(pgrep -f "Gnome-Background-Slideshow.sh" | wc -l)
if [ "$n" = 0]; then 
		echo "Program is not currently running."
		exit 0
else
  pkill -f "Gnome-Background-Slideshow.sh"
