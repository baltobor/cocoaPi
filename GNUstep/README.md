= GNUstep build script

Copyright (c) 2014 by Jacek Wisniowski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


== How To Use

THIS SCRIPT IS EXPERIMENTAL! IT IS VERY PROBABLE THAT YOUR RASPBERRY'S COMPILER
IS NOT WORKING ANYMORE AFTER EXECUTING THIS SCRIPT. USE AT OWN RISK AND ONLY IF
YOU REALLY KNOW WHAT YOU ARE DOING.

Known Bugs: After compiling the linker is not working anymore.
Maybe setting LD_LIBRAY_PATH or entries in /etc/ fixes this issue.
Linker paths can be set in /etc/ld.so.conf.d/libc.conf? 

This folder contains a simple script which downloads and uncompresses all
needed GNUstep packages. Then each packet is being compiled using settings for
obectiveC ARC with Grand Central Dispatch.

This software comes withoud warranty and is intended for use on 
raspberry Pi using raspbian OS.

Installing packages using apt-get is the preferred way. Pleas don't run
this script if your compiler and objC is working.

Ensure that you installed the following packages using apt-get:

sudo apt-get install build-essential clang libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev gobjc libxml2-dev libjpeg-dev libtiff-dev libpng12-dev libcups2-dev libfreetype6-dev libcairo2-dev libxt-dev libgl1-mesa-dev
sudo apt-get install libdispatch-dev
sudo apt-get install libicu-dev
sudo apt-get install git


Your raspberry Pi should have established an internet connection.

If you prepared everything,
start the script with

> ./buildGNUstep.sh


Good luck!
