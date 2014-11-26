**cocoaPi** contains example code and tutorials on how to use objectiveC, GNUstep and ARC on RaspberryPi

# How does it work?

This project contains some scripts and some collected examples to quickly get started with objC development on raspberry Pi.

![ScreenShot](http://blog.tlensing.org/wp-content/uploads/2013/02/gnustep_gui_objective_c_on_ubuntu.jpg)

After cloning this git repository you will see certain folders which are described as follows:

- easyObjectiveC.sh<br/>
  _Is a small script wich //apt-get// the needed packages for you. Depending on your version paths and files are being fixed for you._

- GNUstep<br/>
  _This folder contains a script which downloads uncompresses and compiles GNUstep and libobjC2. In most cases you should not use it. Right now this script comes with this bundle for reference only. It contains some collected knowledge on how to compile GNUstep. In most cases the linker or the compiler will not work after running the script. Maybe it is necessary to change linker paths or some files in /etc afterwards. It's better not to use it if packet installation using //apt-get// worked properly. If you like you can share your knowledge to enhance this script._

- objC<br/>
  _This folder contains example projects to test your objectiveC environment. I collected some source code on the internet to provide you some test files. Big thanks for this go to Tobias Lensing and ljackman. In //baltobor// you will find my examples and you will learn how to use GNUmakefiles._

- tools<br/>
  _This folder contains useful tools and ports for use with raspberry pi._

# Manual installation hints

## raspbian image (2014-09-12)
- Installation<br/>
  _sudo apt-get install build-essential clang libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev gobjc libxml2-dev libjpeg-dev libtiff-dev libpng12-dev libcups2-dev libfreetype6-dev libcairo2-dev libxt-dev libgl1-mesa-dev gnustep-make libdispatch-dev libgnustep-base-dev libobjc4 libobjc2 gnustep-examples gnustep-base-common gnustep-back-common gnustep-devel gnustep-gui-common libgnustep-base-dev libgnustep-gui-dev_

- GNUstep make<br/>
- GNUstep base V0.22.0<br/>
- GNUstep back<br/>
- Problem with include path while compiling test program in objC/arc_test<br/>
  _Create symbolic link_


