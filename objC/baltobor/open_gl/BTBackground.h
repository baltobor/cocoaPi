//
//  BTBackground.h
//
//  Created by Jacek Wisniowski on 09.04.13.
//

#import "BTAtom.h"

@interface BTBackground : BTAtom
+(BTBackground*) backgroundWithRed:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue;
@end
