// Hints:
// compile using make (GNUmakefile must be there)
// it compiles to open_gl.app
// run it with 'openapp ./open_gl'
// Created by Jacek Wisniowski on 26.11.14.

#include <Foundation/Foundation.h>

#import "BTDirector.h"

#include  "bcm_host.h"

#include <GLES/gl.h>
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <time.h>

// a few global vars
bool 		_keepRunning = NO;
uint32_t 	screen_width;
uint32_t 	screen_height;

// OpenGL|ES objects
EGLDisplay display;
EGLSurface surface;
EGLContext context;


void sigterm_handler(int i)
{
	NSLog(@"SIGTERM");
	_keepRunning = NO;
}

void initGLES() {
	
	// !!! HINT !!!: if "libEGL warning: DRI2: xcb_connect failed" appears on the terminal,
	// installation of some libs failes.
	// If gl is showing errors, then the library path to raspberry pi firmware is not found.
	// then we have a problem with LD_LIBRARY_PATH environment variable
	// in this case add path to /opt/vc/lib
	// i.e. 
	// export LD_LIBRARY_PATH=/root/GNUstep/Library/Libraries:/opt/vc/lib/:/usr/lib
	
	int32_t success = 0;
	EGLBoolean result;
	EGLint num_config;

	static EGL_DISPMANX_WINDOW_T nativewindow;

	DISPMANX_ELEMENT_HANDLE_T dispman_element;
	DISPMANX_DISPLAY_HANDLE_T dispman_display;
	DISPMANX_UPDATE_HANDLE_T dispman_update;
	VC_RECT_T dst_rect;
	VC_RECT_T src_rect;

	static const EGLint attribute_list[] =
	{
	  EGL_RED_SIZE, 8,
	  EGL_GREEN_SIZE, 8,
	  EGL_BLUE_SIZE, 8,
	  EGL_ALPHA_SIZE, 8,
	  EGL_DEPTH_SIZE, 16,
	  //EGL_SAMPLES, 4,
	  EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
	  EGL_NONE
	};
   
	EGLConfig config;

	// get an EGL display connection
	display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	assert(display!=EGL_NO_DISPLAY);

	// initialize the EGL display connection
	result = eglInitialize(display, NULL, NULL);
	assert(EGL_FALSE != result);

	// get an appropriate EGL frame buffer configuration
   // this uses a BRCM extension that gets the closest match, rather than standard which returns anything that matches
   result = eglSaneChooseConfigBRCM(display, attribute_list, &config, 1, &num_config);
   assert(EGL_FALSE != result);

   // create an EGL rendering context
   context = eglCreateContext(display, config, EGL_NO_CONTEXT, NULL);
   assert(context!=EGL_NO_CONTEXT);

   // create an EGL window surface
   success = graphics_get_display_size(0 /* LCD */, &screen_width, &screen_height);
   assert( success >= 0 );

   NSLog(@"screen size: (%i, %i)", screen_width, screen_height);
   dst_rect.x = 0;
   dst_rect.y = 0;
   dst_rect.width = screen_width;
   dst_rect.height = screen_height;
      
   src_rect.x = 0;
   src_rect.y = 0;
   src_rect.width = screen_width << 16;
   src_rect.height = screen_height << 16;        

   dispman_display = vc_dispmanx_display_open( 0 /* LCD */);
   dispman_update = vc_dispmanx_update_start( 0 );
         
   dispman_element = vc_dispmanx_element_add ( dispman_update, dispman_display,
      0/*layer*/, &dst_rect, 0/*src*/,
      &src_rect, DISPMANX_PROTECTION_NONE, 0 /*alpha*/, 0/*clamp*/, 0/*transform*/);
      
   nativewindow.element = dispman_element;
   nativewindow.width = screen_width;
   nativewindow.height = screen_height;
   vc_dispmanx_update_submit_sync( dispman_update );
      
   surface = eglCreateWindowSurface( display, config, &nativewindow, NULL );
   assert(surface != EGL_NO_SURFACE);

   // connect the context to the surface
   result = eglMakeCurrent(display, surface, surface, context);
   assert(EGL_FALSE != result);

   glMatrixMode(GL_MODELVIEW);
}


int main (void)
{	
	NSLog(@"Creating SIGTERM handler");
	struct sigaction sa;
    sa.sa_handler = &sigterm_handler;
    sigaction(SIGTERM, &sa, NULL);
    
	NSAutoreleasePool *pool;
	pool = [NSAutoreleasePool new];
		
	bcm_host_init();
	initGLES();
	

	// create scenes
	BTDirector* scene = [[BTDirector director] retain];
	
	// This static vars must be set, Q2DVideo and other 
	// pipelines need this
	scene.display = display;
	scene.surface = surface;
	scene.context = context;
	
	struct timespec ts;
	clock_gettime(CLOCK_REALTIME, &ts);
	time_t start_sec = ts.tv_sec;
	NSLog(@"entering application loop.");	
	_keepRunning = YES;

	BOOL clearScreen = YES;
    while(_keepRunning && !scene->exit) {
	    
	    // Get time
	    clock_gettime(CLOCK_REALTIME, &ts);
	    unsigned long ns = ts.tv_nsec;
	    time_t sec = ts.tv_sec - start_sec;
	    
	    // convert time to seconds (float)
	    float t = sec + ((float)ns / 1000000000);
	    
	    // render at time
		[scene renderAtTime:t]; 		
		
		// and swap buffers		
		eglSwapBuffers(display, surface);	
		clearScreen = YES;			
    }
    
    usleep(100000);
     
	NSLog(@"outside application loop");
    [scene release];
    scene = nil;

	
	NSLog(@"exiting 'open_gl' application");
	RELEASE(pool);

	return 0;
}
