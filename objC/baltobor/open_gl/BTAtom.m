//
//  BTAtom.m
//
//  Created by Jacek Wisniowski on 09.04.13.
//

#import "BTAtom.h"
#include <GLES/gl.h>
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>

//#define MEMORY_DEBUG

static NSUInteger objectCount;

static EGLDisplay _display;
static EGLSurface _surface;
static EGLContext _context;

@implementation BTAtom
@synthesize tag;
@synthesize dtag;
@synthesize parent;
@synthesize enabled;


-(float)width {
    
    if (self->widthSet) {
        
        return self->initialWidth * self->scale_x;
    } else {
        
        return 0.;
    }
}

-(void) setWidth:(float)width {
    
    if (self->widthSet) {
        
        if (initialWidth == 0) {
            
            initialWidth = width;
            self->scale_x = 1;
        } else {

            self->scale_x = width / initialWidth;
        }
    } else {
        
        self->initialWidth = width;
        self->anchor_x = width / 2.;
        self->scale_x = 1.;
        self->widthSet = YES;
    }
}

-(float)height{
    
    if (self->heightSet) {
        
        return self->initialHeight * self->scale_y;
    } else {
        
        return 0.;
    }
}

-(void) setHeight:(float)height {
    
    if (self->heightSet) {
        
        if (initialHeight == 0) {
            
            self->initialHeight = height;
            self->scale_y = 1;
        } else {
            
            self->scale_y = height / initialHeight;
        }
    } else {
        
        self->initialHeight = height;
        self->anchor_y = height / 2.;
        self->scale_y = 1.;
        self->heightSet = YES;
    }
}

-(EGLDisplay) display {
	
	return _display;
}

-(void) setDisplay:(EGLDisplay)d {
	
	_display = d;
}

-(EGLDisplay) surface {
	
	return _surface;
}

-(void) setSurface:(EGLSurface)s {
	
	_surface = s;
}

-(EGLDisplay) context {
	
	return _context;
}

-(void) setContext:(EGLSurface)c {
	
	_context = c;
}


//# deconstruction
-(void)dealloc {
    
    // TODO: Make dealloc safe
    //[self setParent:nil];
    //[self set_renderQueue:nil];
    
    if (texture > 0) {
        
        glDeleteTextures(1, &texture);
    }
    
    if (texture2 > 0) {
        
        glDeleteTextures(1, &texture2);
    }
    
    if (fbTexture > 0) {
        
        glDeleteTextures(1, &fbTexture);
    }
    
    if (vbo > 0) {
        
        glDeleteBuffers(1, &vbo);
    }
    
    if (vbo_texture_coords > 0) {
        
        glDeleteBuffers(1, &vbo_texture_coords);
    }
    
    if (vbo_colors > 0) {
        
        glDeleteBuffers(1, &vbo_colors);
    }
    
    objectCount--;
    
    #ifdef MEMORY_DEBUG
    NSLog(@"dealloc %@, objects living: %li", [self class], (unsigned long)objectCount);
    #endif
    
    [super dealloc];
}


// # Construction
-(id) init {
    
    self = [super init];
    if (self) {
        
        self->initialized = NO;
        
        // In the scene graph fade is a factor which is being multiplied
        // to the alpha value of all children.
        self->_alphaFade = 1.;
        self->_colorFade = 1.;
        self->cF = 1.;
        self->aF = 1.;
        self->enabled = YES;
        self->pause = NO;
        
        // size setters and getters functionlity
        self->widthSet = NO;
        self->heightSet = NO;
        self->scale = 1.;
        self->scale_x = 1.;
        self->scale_y = 1.;
        self->rotation = 0;
        
        objectCount++;
        #ifdef MEMORY_DEBUG
        NSLog(@"init %@, objects living: %li", [self class], (unsigned long)objectCount);
        #endif
    }
    
    return self;
}


// Forward and backwards transform was introduced,
// because the stack of openGL is too low.
-(void) forwardTransform {
    
    glTranslatef(self->pos_x + self->x, self->pos_y + self->y, 0);
    
    // rotate around anchorpoint
    glRotatef(self->rotation, 0, 0, 1.);
    glTranslatef(-self->anchor_x*self->scale, -self->anchor_y*self->scale, 0);
    glScalef(self->scale_x * self->scale, self->scale_y * self->scale, 1.);
}

-(void) backwardTransform {
    
    // TODO: make sure the scalevalues are never 0
    // Fix this
    
    // take back rotation arount anchorpoint
    glScalef(1./(self->scale_x * self->scale), 1. / (self->scale_y * self->scale), 1.);
    glTranslatef(self->anchor_x*self->scale, self->anchor_y*self->scale, 0);
    glRotatef(-self->rotation, 0, 0, 1.);
    
    glTranslatef(-self->pos_x - self->x, -self->pos_y - self->y, 0);
}

-(void) renderAtTime:(NSTimeInterval)t {
    
    // errorlog
    [self logGlError];
    
    // traverse children (treetraversal)
    if (self->_renderQueue) {
        
        for (id object in self->_renderQueue) {
            
            if (object) {
                
                if ([object enabled]) {

                    [object renderAtTime:t];
                }
            }
        }
    }
    
    // children should call this method always AFTER drawing
}


//#pragma mark scene graph
-(void) addObject:(id)object {

    if (!object) return;
    
    [object setParent:self];

    if (!self->_renderQueue) {
        
        self->_renderQueue = [NSMutableArray array];
    }     
    [self->_renderQueue addObject:object];    
}

-(void) removeObject:(id)object {
    
    if (!object) return;
    	
    if (self->_renderQueue) {
        
        [self->_renderQueue removeObject:object];
    }
}

-(void) removeAllObjects {
    
    [self->_renderQueue release];
    self->_renderQueue = nil;
}

-(NSArray*) children {
    
    return [[NSArray arrayWithArray:self->_renderQueue] autorelease];
}

-(void) setChildren:(NSArray *)children {
    
    // don't set children here.
    // use addObject instead
}

// the parent object can specify a fade argument which is being multiplied with the alpha value. Default == 1.
-(void) setAlphaFade:(float) value {
    
    self->_alphaFade = value;
}

-(float) alphaFade {
    
    BTAtom* pObject = self.parent;
    float value = self->_alphaFade;
    while (pObject) {

        float val = pObject->_alphaFade;
        value = value * val;
        pObject = pObject.parent;
    }
    
    return value;
}


-(void) setColorFade:(float)value {
    
    self->_colorFade = value;
}

-(float) colorFade {
    
    BTAtom* pObject = self.parent;
    float value = self->_colorFade;
    while (pObject) {
        
        float val = pObject->_colorFade;
        value = value * val;
        pObject = pObject.parent;
    }
    
    return value;
}


-(void) resume {            // abstract method for custom purpose

    self->pause = NO;
}

-(void) pause {             // abstract method for custom purpose
 
    self->pause = YES;
}

-(BOOL) finished {          // abstract method for custom purpose
    
    return NO;
}

-(void) reset {             // abstract method for custom purpose
    
    self->pause = NO;
}

-(void) destroy {
    
    // compatibility
}

+(BTAtom*) atom {
    
    return [[[BTAtom alloc] init] autorelease];
}

+(NSUInteger) livingObjects {
    
    return objectCount;
}

-(void) logGlError {
    
    NSString* errorString;
    BOOL retVal = NO;
    do {
        
        retVal = NO;
        GLenum err = glGetError();
        switch( err )
        {
            case GL_NO_ERROR: {
              
                retVal = YES;
            } break;
                
            case GL_INVALID_ENUM: {
                
                errorString = @"GL_INVALID_ENUM";
            } break;
                
            case GL_INVALID_VALUE: {
                
                errorString = @"GL_INVALID_VALUE";
                break;
            }
                
            case GL_INVALID_OPERATION: {
              
                errorString = @"GL_INVALID_OPERATION";
            } break;
                
            case GL_INVALID_FRAMEBUFFER_OPERATION: {
               
                errorString = @"GL_INVALID_FRAMEBUFFER_OPERATION";
            } break;
                
            // OpenGLES Specific Errors

            case GL_STACK_OVERFLOW: {
                
                errorString = @"GL_STACK_OVERFLOW";
            } break;
                
            case GL_STACK_UNDERFLOW: {
                
                errorString = @"GL_STACK_UNDERFLOW";
            } break;
                
            case GL_OUT_OF_MEMORY: {
                errorString = @"GL_OUT_OF_MEMORY";
            } break;
                
            default: {
                
                errorString = [NSString stringWithFormat:@"UNKNOWN: %x", err];
            } break;
        }
        
        if( !retVal )
        {
            
            NSLog(@"glError: %@: %@\n", [self class], errorString );
        }
    } while (!retVal);
}

-(void) ClearErrors {
    
    while( glGetError() != GL_NO_ERROR );
}

@end
