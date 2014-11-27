include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = open_gl
open_gl_HEADERS = BTConstants.h BTAppKit.h BTHelpers.h BTAtom.h BTBackground.h BTSprite.h BTDirector.h
open_gl_OBJC_FILES = main.m BTAppKit.m BTHelpers.m BTGlobals.m BTAtom.m BTBackground.m BTSprite.m BTRegie.m

open_gl_RESOURCE_FILES = images/darth@2x.png images/debris@2x.png
 
# -std=c99 is needed for declaring vars infide for loop i.e. for (int i; ...) (else i must be declared outside) (conflicting with vcos, don't use here)
open_gl_CPPFLAGS = $(RUNTIME_DEFINE) -I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux/ -lbcm2835

# ilclient.o ilcore.o are extracted by using 'ar x liilclient.a' in /opt/vc/src/hello_pi/libs/ilclient
# -lrt -> high resolution clock
# -lbcm2835
# -L/opt/vc/src/hello_pi/libs/ilclient
open_gl_LDFLAGS = bcm2835.o -lpthread -lm -lrt -lGLESv2 -lEGL -lopenmaxil -lbcm_host -lvcos -lvchiq_arm -lpng -ljpeg -lwiringPi -lmp4v2 -L/opt/vc/lib/  -L/usr/lib 


#open_gl_INCLUDE_DIRS =

#open_gl_ADDITIONAL_CPPFLAGS =
#open_gl_ADDITIONAL_OBJCFLAGS = 
#open_gl_ADDITIONAL_CFLAGS =
#open_gl_ADDITIONAL_CPPFLAGS =

#open_gl_ADDITIONAL_LIB_DIRS =
#open_gl_ADDITIONAL_OBJC_LIBS =

#open_gl_ADDITIONAL_LDFLAGS =


include $(GNUSTEP_MAKEFILES)/application.make