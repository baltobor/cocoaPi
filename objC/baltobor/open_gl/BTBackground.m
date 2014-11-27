//
//  BTBackground.m
//
//  Created by Jacek Wisniowski on 09.04.13.
//

#import "BTBackground.h"

@implementation BTBackground

+(BTBackground*) backgroundWithRed:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue {
    
    BTBackground* bg = [[BTBackground alloc] init];
    bg->red = red;
    bg->green = green;
    bg->blue = blue;
    bg->initialized = NO;
    
    return [[bg retain] autorelease];
}

-(void) renderAtTime:(NSTimeInterval)t {
            
    glClearColor(self->red/255., self->green/255., self->blue/255., 1.);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    
    // map the render size to viewport size
    glOrthof(0, BTWidth, BTHeight, 0, 0, 100.0f);
    

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    
    // Call super class at the end to enable tree traversal
    [super renderAtTime:t];
}
@end
