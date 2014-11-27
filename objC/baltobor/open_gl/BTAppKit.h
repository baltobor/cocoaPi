//
//  BTAppKit.h
//
//  Created by Jacek Wisniowski on 27.03.2014
//

#ifndef __BT_APP_KIT__
#define __BT_APP_KIT__

typedef float CGFloat;  // 32-bit

struct CGPoint {
   CGFloat x;
   CGFloat y;
};
typedef struct CGPoint CGPoint;

struct CGSize {
   CGFloat width;
   CGFloat height;
};
typedef struct CGSize CGSize;

struct CGRect {
   CGPoint origin;
   CGSize size;
};
typedef struct CGRect CGRect;

CGSize CGSizeMake(CGFloat width, CGFloat height);


#endif