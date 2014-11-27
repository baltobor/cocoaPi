**HINT:** This project is tested and works with arch linux. Testing and tutorial for raspbian must be done. 

# How to prepare raspberryPi for this program:

- update: sudo apt-get update
- sudo apt-get install base-devel
- sudo apt-get install gnustep
- sudo apt-get install build-essential
- sudo apt-get install gobjc
- sudo apt-get install gcc
- sudo apt-get install libpng
- sudo apt-get install wiringpi	

	
- For font-Support install
	sudo apt-get install freetype2
	sudo apt-get install ttf-ubuntu-font-family


# Prepare userland and libs

compile ilclientlib.
extract objects with ar -x libilclient.a
copy .o files to project folder, copy ilclient.h to project folder
use separate userland repository for that.
Source:
https://github.com/raspberrypi/userland

