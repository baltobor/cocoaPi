//
//  BTDirector.h

//  Created by Jacek Wisniowski on 26.11.14.

#import "BTAtom.h"
#import "BTBackground.h"
#import "BTSprite.h"
#include <pthread.h>

#define BT_STATE_START 0
#define BT_STATE_MOVE_DEBRIS 1

#define DEBRIS_COUNT 4
#define VELOCITY_MAX 20.0


@interface BTDirector : BTAtom {
	
	pthread_t 		buttonThreadId;
	pthread_t 		bdriveThreadId;
	
	pthread_t 		videoThreadId;
	
	
@public

	BOOL			exit;
	BOOL			gpioThreadEnabled;
	BOOL 			gpioThreadRunning;
	
	NSUInteger      presentationState;
    
    NSTimeInterval  lastTime;
     
    NSUInteger		frames;
            
    // scene objects
    BTBackground* 	background;
	BTAtom* 		skyLayer;
	BTAtom* 		earthLayer;
	
	BTSprite*		spaceDebris[DEBRIS_COUNT];
	BTSprite*		earth;
	
	float 			debrisVelocityX[DEBRIS_COUNT];
	float 			debrisVelocityY[DEBRIS_COUNT];
	float 			debrisRotVel[DEBRIS_COUNT];
               
    int				ticksCounter;
    
    BOOL 			go_left;
    BOOL 			go_right;
	BOOL 			go_up;
    BOOL 			go_down;
}

+(BTDirector*) director;
@end
