//
//  BTAtom.h
//  Created by Jacek Wisniowski on 09.04.13.
//

#import <Foundation/Foundation.h>
#import "BTAppKit.h"				// Contains CGPoint, etc.
#import "BTConstants.h"

#include <GLES/gl.h>
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>


// We use a user defined block for collision interaction and scripting
@interface BTAtom : NSObject {
    

    GLuint vbo;         // stores a vertex buffer object
    GLuint vbo_colors;
    GLuint vbo_texture_coords;
    
    GLuint texture;     // these textures should be used. These buffers will be recycled automatically
    GLuint texture2;

    GLuint fbTexture;   // This texture is reserved for framebuffers. Will be recycled automatically
    GLuint framebuffer;
    GLuint renderbuffer;
    BOOL initialized;
    
    // This is used internally. It's the accumulated alpha fade and color fade arguments
    // which can be used immediately inside the renderer
    float aF;
    float cF;

    BOOL pause;
    
    // locals (in ARC: category)  
    float initialWidth;
    float initialHeight;
    BOOL  widthSet;
    BOOL  heightSet;
    
	// iVars:
	unsigned long tag;
	float dtag;

	NSMutableArray* _renderQueue;
	BOOL enabled;
	id parent;

	float _alphaFade;
	float _colorFade;

@public
	GLfloat x;                 // object x
	GLfloat y;                 // object y
	GLfloat anchor_x;          // user defined midpoint x
	GLfloat anchor_y;          // user defined midpoint y
	GLfloat scale;             // global scale factor
	GLfloat scale_x;           // scale factor for x axis
	GLfloat scale_y;           // scale factor for y axis
	GLfloat pos_x;             // actual position ofset x (animation)
	GLfloat pos_y;             // actual position ofset y (animation)
	GLfloat rotation;          // actual object rotation

	unsigned char red;
	unsigned char green;
	unsigned char blue;
	unsigned char alpha;
}

@property EGLDisplay display;
@property EGLSurface surface;
@property EGLContext context;

@property BOOL enabled;

@property float width;             // object width
@property float height;            // object height

@property unsigned long tag;
@property float dtag;

// Transitions
@property float alphaFade;  // the parent object can specify a fade argument which is being multiplied with the alpha value. Default == 1.
@property float colorFade;  // the parent object can specify a fade argument which is being multiplied with the alpha value. Default == 1.

@property (nonatomic, assign) id parent;
@property (nonatomic, retain) NSArray* children;


-(void) addObject:(id)object;       // Adds an object to the renderers scene graph
-(void) removeObject:(id)object;    // removes given object from scene graph
-(void) removeAllObjects;


-(void) forwardTransform;               // perform translations, scaling and rotation with respect to the scene graph
-(void) renderAtTime:(NSTimeInterval)t; // render input is actual sensor data like mouse or 3Dsenors
-(void) backwardTransform;              // take back translations, scaling and rotation with respect to the scene graph


-(void) resume;     // abstract method for custom purpose
-(void) pause;      // abstract method for custom purpose
-(BOOL) finished;   // abstract method for custom purpose
-(void) reset;      // abstract method for custom purpose
-(void) destroy;


// convenience. Simply returns an alloced and initialized atom
+(BTAtom*) atom;


+(NSUInteger) livingObjects;


-(void)logGlError;
@end
