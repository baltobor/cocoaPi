//
//  BTSprite.h
//
//  Created by Jacek Wisniowski on 09.04.13.
//

#import "BTAtom.h"

#include <pthread.h> // multithreading instead of dispatch_queues

// The new  Version of lib-png12 has changed a lot
// We need to define PNG_SKIP_SETJMP_CHECK
// else the compiler drops an error in 
// /usr/include/pngconf.h
// which is a hint to define PNG_SKIP_SETJMP_CHECK ;-)
#define PNG_SKIP_SETJMP_CHECK
#include <png.h>
#include <jpeglib.h>

@interface BTSprite : BTAtom {

@public
	pthread_t	tid;

    int   mode;
    float originX;
    float originY;
    float centerX;
    float centerY;
    CGRect frame;
    
	int file_width;
	int file_height;
    
    BOOL  imageLoaded;
    BOOL  imagePrepared;
    BOOL  doubleSized;
    
    NSString* filePath;
	png_byte* image_data;
	
	// iVars
	BOOL redraw;
	BOOL mipmapfilter;
}


@property BOOL redraw;  		// if YES, actual "self.image" will be drawn to the glContext
@property BOOL mipmapfilter;

+(BTSprite*) spriteWithFilename:(NSString*)file originX:(float)x originY:(float)y;
+(BTSprite*) spriteWithFilename:(NSString*)file centerX:(float)x centerY:(float)y;
+(BTSprite*) spriteWithFilename:(NSString*)file frame:(CGRect)frame;
@end
