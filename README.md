**cocoaPi** contains example code and tutorials on how to use objectiveC, GNUstep and ARC on RaspberryPi

# How does it work?

This project contains some scripts and some collected examples to quickly get started with objC development on raspberry Pi.

![ScreenShot](http://blog.tlensing.org/wp-content/uploads/2013/02/gnustep_gui_objective_c_on_ubuntu.jpg)

After cloning this git repository you will see certain folders which are described as follows:

- easyObjectiveC.sh<br/>
  _Is a small script wich _apt-get_'s the needed packages for you. Depending on your version paths and files are being fixed for you._

- GNUstep<br/>
  _This folder contains a script which downloads uncompresses and compiles GNUstep and libobjC2. In most cases you should not use it. Right now this script comes with this bundle for reference only. It contains some collected knowledge on how to compile GNUstep. In most cases the linker or the compiler will not work after running the script. Maybe it is necessary to change linker paths or some files in /etc afterwards. It's better not to use it if packet installation using _apt-get_ worked properly. If you like you can share your knowledge to enhance this script._

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

