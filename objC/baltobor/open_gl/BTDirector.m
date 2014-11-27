//
//  BTDirector.m
//  Created by Jacek Wisniowski on 26.11.14.


// some defaults
unsigned int led1 = 4;
unsigned int led2 = 5;
unsigned int up_button    = 0;
unsigned int down_button  = 1; 
unsigned int left_button  = 2;
unsigned int right_button = 3; 

// open gl scene renderer
#import "BTDirector.h"


#include <wiringPi.h>			// gpio interface
#include <wiringPiI2C.h>		// i2c interface
#include <bcm2835.h>
#include <wiringSerial.h>		// RS232 interface



void* gpioHandler(void* arg) {


	NSAutoreleasePool *pool;
	pool = [NSAutoreleasePool new];
		
	[[NSUserDefaults standardUserDefaults] synchronize];
		
	led1 = (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:@"led1"];
	led2 = (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:@"led2"];
	
	up_button    = (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:@"up_button_port"];
	down_button  = (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:@"down_button_port"];
	left_button  = (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:@"left_button_port"];
	right_button = (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:@"right_button_port"];
	
	NSLog(@"Led1: %i, Led2: %i", led1, led2);
													
	BTDirector* self = (BTDirector*)arg;
	
	self->gpioThreadRunning = YES;
		
	// init gpio
	NSLog(@"setting up gpio");
	wiringPiSetup();

	// Wiring is using another table than the GPIO layout.
	// the mapping is as followed:
	// +----------+-Rev2-+------+--------+
	// | wiringPi | GPIO | Phys | Name   |
	// +----------+------+------+--------+
	// |      0   |  17  |  11  | GPIO 0 | 
	// |      1   |  18  |  12  | GPIO 1 | 
	// |      2   |  27  |  13  | GPIO 2 |     
	// |      3   |  22  |  15  | GPIO 3 | 
	// |      4   |  23  |  16  | GPIO 4 | 
	// |      5   |  24  |  18  | GPIO 5 | 
	// |      6   |  25  |  22  | GPIO 6 | 
	// |      7   |   4  |   7  | GPIO 7 | 
	// |      8   |   2  |   3  | SDA    |
	// |      9   |   3  |   5  | SCL    |
	// |     10   |   8  |  24  | CE0    |
	// |     11   |   7  |  26  | CE1    | 
	// |     12   |  10  |  19  | MOSI   |
	// |     13   |   9  |  21  | MISO   |
	// |     14   |  11  |  23  | SCLK   | 
	// |     15   |  14  |   8  | TxD    |
	// |     16   |  15  |  10  | RxD    |
	// |     17   |  28  |   3  | GPIO 8 | 
	// |     18   |  29  |   4  | GPIO 9 |
	// |     19   |  30  |   5  | GPIO10 |
	// |     20   |  31  |   6  | GPIO11 |
	// +----------+------+------+--------+
	
	// Setup buttons
	// left button (previous)
	pinMode (left_button, INPUT);  
	pullUpDnControl(left_button, PUD_DOWN); // pull down to gnd to release the button properly
	
	// right button
	pinMode (right_button, INPUT);  
	pullUpDnControl(right_button, PUD_DOWN); // pull down to gnd to release the button properly
	
	// up button
	pinMode (up_button, INPUT);  
	pullUpDnControl(up_button, PUD_DOWN); // pull down to gnd to release the button properly
	
	// down button
	pinMode (down_button, INPUT);  
	pullUpDnControl(down_button, PUD_DOWN); // pull down to gnd to release the button properly
	
	
	// setup LEDs
	pinMode (led1, OUTPUT);
	digitalWrite (led1, LOW);
	
	pinMode (led2, OUTPUT);
	digitalWrite (led2, LOW);
		
	self->ticksCounter = 0;	
	
	int blinker = 0;
	bool ledState = NO;

	while(self->gpioThreadEnabled) {

		blinker++;
					
		if ((blinker % 4) == 0) {
	
			ledState = !ledState;					
		} 
				
		if (ledState) {
											
			digitalWrite (led1, HIGH);
		} else {
			
			digitalWrite (led1, LOW);
		}
			

		int b;					 
		// read all buttons in a loop
		for (b = 0; b < 4; b++)	{
		
			int buttonId = 0;
			switch(b) {
				
				case 0: {
					
					buttonId = left_button;
				} break;
				
				case 1: {
					
					buttonId = right_button;
				} break;
				
				case 2: {
					
					buttonId = up_button;
				} break;
				
				case 3: {
					
					buttonId = down_button;
				} break;
								
				default: {
					
				} break;
			}
			
			// inverted button logic
			// LOW means button is pushed
			int buttonState = digitalRead(buttonId);
			bool pushAction = false;
			bool releaseAction = false;
			
			if ((LOW == buttonState) && !debounce[buttonId]) {
			
				pushAction = true;
				debounce[buttonId] = true;
			} 
			
			if ((HIGH == buttonState) && debounce[buttonId]) {
			
				releaseAction = true;
				debounce[buttonId] = false;				
			}			
						
			
			switch (buttonId) {
				
				case left_button: {
					
					if (pushAction) {
						
						go_left = YES;
					}
					
					if (releaseAction) {
						
						go_left = NO;
					}
				} break;
				
				case right_button: {
									
					if (pushAction) {
					
						go_right = YES;	
					}					
					
					if (releaseAction) {
						
						go_right = NO;	
					}	
				} break;

				case up_button: {
						
					if (pushAction) {
						
						go_up = YES;
					}
					
					if (releaseAction) {
											
						go_up = NO;				
					}				
				} break;
				
				case down_button: {
				
					if (pushAction) {
						
						go_down = YES;
					}
					
					if (releaseAction) {
						
						go_down = NO;
					}			
				} break;												
			}				
		}		 
														 								
		usleep(100000); self->ticksCounter++;
		
			
	RELEASE(pool);
	
	self->gpioThreadRunning = NO;
	
	return NULL;
}


@implementation BTDirector

-(void)safeRelease:(id*)handle {
	
	if (handle) {
		
		[*handle release];
		*handle = nil;
	}
}

-(void)dealloc {
    
    self->gpioThreadEnabled = NO;

	while (gpioThreadRunning) {
		
		usleep(10000);
	}
	
	[self removeAllObjects];
		    
	[self safeRelease:&self->background];
	[self safeRelease:&self->skyLayer];
	[self safeRelease:&self->earthLayer];
       
    [super dealloc];
}


-(void) buildScene {
    
    int i
    
    self->presentationState = BT_STATE_START;
        
    self->background = [BTBackground backgroundWithRed:0 green:0 blue:0];
    self->background.parent = self;
    [self addObject:self->background];
    
    self->earth = [BTSprite spriteWithFilename:[BTHelpers pathForRessource:@"earth.png" atPath:@"/images/"] centerX:BTWidth / 2. centerY:BTHeight / 2.];
	[self->earth retain];
	

	// Create layers	
    self->skyLayer = [BTAtom atom];
    self->earthLayer = [BTAtom atom];
	[self addObject:self->skyLayer];
    [self addObject:self->earthLayer];

	// create sprites
	for (i = 0; i < DEBRIS_COUNT; i++) {
    	
    	self->spaceDebris[i] = [BTSprite spriteWithFilename:[BTHelpers pathForRessource:@"debris.png" atPath:@"/images/"] centerX:BTWidth / 2. centerY:BTHeight / 2.];
		[self->spaceDebris[i] retain];
	}
        
    [self->earthLayer addObject:self->earth];
    
    for (i = 0; i < DEBRIS_COUNT; i++) {

	    [self->skyLayer addObject:self->spaceDebris[i]];
    }    


	// Setup button controller
	self->gpioThreadEnabled = YES;
	pthread_create(&buttonThreadId, NULL, gpioHandler, (void*)self);
	
    NSLog(@"initialized");
}


+(BTDirector*) director {
    
    BTDirector* director = [[BTRegie alloc] init];
    diretor->exit = NO;
    [director buildScene];
    
    return [director autorelease];
}

/**
 renderAtTime: is the main render loop. It is initialized in main.m. BTBackground is the root of the scene graph and initializes all.
*/
-(void) renderAtTime:(NSTimeInterval)t {
    
    int i      
           
    switch (self->presentationState) {
        case BT_STATE_START: {

			for (i = 0; i < DEBRIS_COUNT; i++) {
				
				debrisVelocityX[i] = rand() * VELOCITY_MAX / RAND_MAX;
				debrisVelocityY[i] = rand() * VELOCITY_MAX / RAND_MAX;
				debrisRotVel[i] =  = rand() * VELOCITY_MAX / RAND_MAX;
			}

            self->lastTime = t;
            self->presentationState = BT_STATE_MOVE_DEBRIS;
        } break;
            

        case BT_STATE_MOVE_DEBRIS: {
            
            for (i = 0; i < DEBRIS_COUNT; i++) {
	            
	            self->spaceDebris[i].posX += debrisVelocityX[i];
	            self->spaceDebris[i].posY += debrisVelocityY[i];
	            self->spaceDebris[i].rotation += debrisRotVel[i];
	            
	            if (self->spaceDebris[i].posX < 0) {
		            
		            self->spaceDebris[i].posX += BTWidth;
	            }
	            
	            if (self->spaceDebris[i].posX > BTWidth) {
		            
		            self->spaceDebris[i].posX -= BTWidth;
	            }
	            
	            if (self->spaceDebris[i].posY < 0) {
		            
		            self->spaceDebris[i].posY += BTHeight;
	            }
	            
	            if (self->spaceDebris[i].posY > BTWidth) {
		            
		            self->spaceDebris[i].posY -= BTHeight;
	            }
	        }
        } break;                
	}
       
    [super renderAtTime:t];
}

@end
