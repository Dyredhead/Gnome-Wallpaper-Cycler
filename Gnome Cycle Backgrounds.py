#!/usr/bin/python

from importlib.resources import path
import os, sys, random, time

def read_args(args):
	path = os.path.expandvars("$HOME/Pictures/Wallpapers/")
	i = find_arg(args, "path")
	if i != -1:
		path: str = os.path.expandvars(read_arg(args, i))

	randomize = False
	i = find_arg(args, "randomize")
	if i != -1:
		randomize: bool = read_arg(args, i) == "True"

	delay = 60
	i = find_arg(args, "delay")
	if i != -1:
		delay: int = int(read_arg(args, i))
	
	cycle = True
	i = find_arg(args, "cycle")
	if i != -1:
		cycle: bool = read_arg(args, i) == "True"

	return path, randomize, delay, cycle

def find_arg(args, key) -> int:
	for i, arg in enumerate(args):
		if arg.find(key) != -1: return i
	return -1

def read_arg(args, i) -> str:
	return args[i].split("=")[1]


def main(path, randomize, delay, cycle) -> None:
	print(f"path: {path}")
	print(f"randomize: {randomize}")
	print(f"delay: {delay}")
	print(f"cycle: {cycle}")

	print()

	backgrounds = os.listdir(path)
	if randomize: random.shuffle(backgrounds)
	print(f"# of backgrounds: {len(backgrounds)}")
	print(f"backgrounds: {backgrounds}") 

	while True:
		for background in backgrounds:
			change_background(path, background)
			time.sleep(delay)
		if not cycle: break	
		
def change_background(path, background):
	os.system("gsettings set org.gnome.desktop.background picture-uri \""+path+"/"+background+"\"")
	os.system("gsettings set org.gnome.desktop.background picture-uri-dark \""+path+"/"+background+"\"")

if __name__ == "__main__":
	path, randomize, delay, cycle = read_args(sys.argv)
	main(path, randomize, delay, cycle)
