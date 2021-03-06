**HINT:** This project is actually not working properly. Please wait until this hint is removed before you test otherwise your raspberry sd-card image could be damaged.

**cocoaPi** contains example code and tutorials on how to use objectiveC, GNUstep and ARC on RaspberryPi. This archive was created for a presentation at cocoaHeads Aachen:<br/>
- http://hci.rwth-aachen.de/cocoaheads

If you are next to Aachen and would like to meet interesting people visit us at Digitac:<br/>
- http://digitac.cc
- http://facebook.com/DigitalesAachen

According to David Chisnall (GNUstep mailinglist) my build script in folder GNUstep is not working because the version of clang is 'archaic'. Unfortunately this is the clang version which is distributed with raspbian actually. Thanks to his advice I learned, that the freeBSD port is always using the newest clang. Therefore I recommend to use FreeBSD for RaspberryPi now. I will try to find out how to crosscompile llvm. Unfortunately the actual source of llvm now dislikes the gcc version of raspbian. For now I am skipping raspbian and trying getting modern objC to run using FreeBSD. I want to say greetings to Riccardo Mottola, too. He helped me with some elementary questions on how to get started.

Here is the source of FreeBSD for Raspberry PI: https://wiki.freebsd.org/FreeBSD/arm/Raspberry%20Pi
According to Admin magazine FreeBSD is en extremely stable linux for RaspberryPI. Therefore - for now - I will switch over to FreeBSD. (http://www.admin-magazin.de/Das-Heft/2014/03/FreeBSD-auf-Raspberry-Pi/(offset)/2)
FreeBSD, getting started: https://fosskb.wordpress.com/2014/11/29/getting-started-with-freebsd-on-raspberry-pi/

# How does it work?

This project contains some scripts and some collected examples to quickly get started with objC development on raspberry Pi.

![ScreenShot](http://blog.tlensing.org/wp-content/uploads/2013/02/gnustep_gui_objective_c_on_ubuntu.jpg)

After cloning this git repository you will see certain folders which are described as follows:

- easyObjectiveC.sh<br/>
  _Is a small script wich _apt-get_'s the needed packages for you. Depending on your version paths and files are being fixed for you. Right now you cannot use it because raspbian is still using too old versions of clang and gcc. I think we need to wait some time until this script can be used on raspbian_

- GNUstep<br/>
  _This folder contains a script which downloads uncompresses and compiles GNUstep and libobjC2. On raspbian you first need to crosscompile llvm before you can use this script. This script contains some collected knowledge on how to compile GNUstep and libobjc2. You need at least llvm 3.4. This script should work with FreeBSD for raspberryPI._

- objC<br/>
  _This folder contains example projects to test your objectiveC environment. I collected some source code on the internet to provide you some test files. Big thanks for this go to Tobias Lensing and ljackman. In //baltobor// you will find my examples and you will learn how to use GNUmakefiles._

- tools<br/>
  _This folder contains useful tools and ports for use with raspberry pi._

- patches<br/>
  _If installation scripts need to patch files, you'll find the patch files here_

# Manual installation hints
  Put the GNUstep shell script into your startup script after installation:
  ```
  /usr/share/GNUstep/Makefiles/GNUstep.sh 
  ```
  Put this line in your profile at startup by adding it to ~/.bashrc 
  
## raspbian image (2014-09-12)
- Installation<br/>
  ```
  sudo apt-get install build-essential clang libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev gobjc libxml2-dev libjpeg-dev libtiff-dev libpng12-dev libcups2-dev libfreetype6-dev libcairo2-dev libxt-dev libgl1-mesa-dev gnustep-make libdispatch-dev libgnustep-base-dev libobjc4 libobjc2 gnustep-examples gnustep-base-common gnustep-back-common gnustep-devel gnustep-gui-common libgnustep-base-dev libgnustep-gui-dev
  ```

- GNUstep make<br/>
- GNUstep base V0.22.0<br/>
- GNUstep back<br/>
- Problem with include path while compiling test program in objC/arc_test<br/>
 GMUstep base tries to ```#include <objc/blocks_runtime.h>```

  _Create symbolic link:_ 
  ```
  sudo ln -s /usr/local/include/GNUstep/objc /usr/local/include/GNUstep/ObjectiveC2
  ```

 or patch file:

  ```
  Index: core/base/Headers/GNUstepBase/GSVersionMacros.h 
  =================================================================== 
  --- core/base/Headers/GNUstepBase/GSVersionMacros.h	(revision 35202) 
  +++ core/base/Headers/GNUstepBase/GSVersionMacros.h	(working copy) 
  @@ -284,7 +284,9 @@ 
  */ 
   #if __has_feature(blocks) 
   #  if	OBJC2RUNTIME 
  -#    include <objc/blocks_runtime.h> 
  +#    ifndef __APPLE__ 
  +#      include <objc/blocks_runtime.h> 
  +#    endif 
   #  else 
   #    include <ObjectiveC2/blocks_runtime.h> 
   #  endif 
  ```
  For more information read: 
  - http://gnustep.8.n7.nabble.com/bug-36650-base-tries-to-include-lt-objc-blocks-runtime-h-gt-with-Apple-runtime-td21824.html
  - https://artinamessage.wordpress.com/2013/06/03/gnustep-install-with-clang-blocks-and-grand-central-dispatch-gcd/

