= How to prepare raspberryPi for this program:

1. update: sudo apt-get update
2. sudo apt-get install base-devel
3. sudo apt-get install gnustep
4. sudo apt-get install build-essential
5. sudo apt-get install gobjc
6. sudo apt-get install gcc
7. sudo apt-get install libpng
8. sudo apt-get install wiringpi	

	
9. For font-Support install
	sudo apt-get install freetype2
	sudo apt-get install ttf-ubuntu-font-family


= Prepare userland and libs

compile ilclientlib.
extract objects with ar -x libilclient.a
copy .o files to project folder, copy ilclient.h to project folder
use separate userland repository for that.
Source:
https://github.com/raspberrypi/userland

