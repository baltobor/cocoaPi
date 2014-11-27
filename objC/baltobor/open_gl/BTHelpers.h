//
//  BTHelpers.h
//
//  Created by Jacek Wisniowski on 10.05.13.
//

#import <Foundation/Foundation.h>
#import "BTAppKit.h"

typedef struct _CGPoint3D {
    
    float x;
    float y;
    float z;
} CGPoint3D;

CGPoint3D CGPoint3DMake(float x, float y, float z);
    
/**
 This class holds some globals which are available from everywhere
 (Static vars)
 */
@interface BTHelpers : NSObject {
	
	NSRect      viewSize;
}

+(BTHelpers*) sharedInstance;

// View properties
-(NSRect)viewSize;
-(void)setViewSize:(NSRect)frame;

//#pragma mark data mamagement
+(NSString*) pathForRessource:(NSString*)name atPath:(NSString*)subPath;

+(NSString*) appPath;
@end
