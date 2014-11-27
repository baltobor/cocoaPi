//
//  BTHelpers.m
//
//  Created by Jacek Wisniowski on 10.05.13.
//
#import "BTHelpers.h"
#import "BTConstants.h"

@implementation BTHelpers

+(BTHelpers*) sharedInstance {
    
    static BTHelpers* theInstance = nil;
    if (!theInstance) {
        
        theInstance = [[BTHelpers alloc] init];
    }
    
    return theInstance;
}


-(NSRect)viewSize {
    
    return self->viewSize;
}

-(void)setViewSize:(NSRect)frame {
    
    self->viewSize = frame;
}


+(NSString*) appPath {
      
    return [[NSBundle mainBundle] resourcePath];
}


+(NSString*) pathForRessource:(NSString*)name atPath:(NSString*)subPath {
    
    if (!name) return nil;
    NSString* ressourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
	return ressourcePath;
}

@end
