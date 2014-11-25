#import <stdbool.h>
#import <stdio.h>
#import <stdlib.h>

#import <Foundation/Foundation.h>

@interface Area : NSObject {
    bool *area;
    size_t width, height;
}

- (id) initWithWidth:(size_t)aWidth height:(size_t)aHeight;
- (void) dealloc;
- (void) display;
@end

@implementation Area

- (id) initWithWidth:(size_t)aWidth height:(size_t)aHeight {
    self = [super init];
    width = aWidth;
    height = aHeight;
    area = malloc((sizeof *area) * aWidth * aHeight);

    for (size_t y = 0; y < aHeight; ++y) {
        for (size_t x = 0; x < aWidth; ++x) {
            area[(aHeight * y) + (aWidth * x)] = true;
        }
    }

    return self;
}

- (void) dealloc {
    free(area);
    puts("DEALLOCATED");
}

- (void) display {
    for (size_t y = 0; y < height; ++y) {
        putchar('|');
        for (size_t x = 0; x < width; ++x) {
            putchar(area[(height * y) + (width * x)]
                    ? '#'
                    : ' ');
        }
        puts("|");
    }
}

@end

int main(void)
{
    @autoreleasepool {
        id area = [[Area alloc] initWithWidth:10 height:10];
        [area display];
    }
    return EXIT_SUCCESS;
}
