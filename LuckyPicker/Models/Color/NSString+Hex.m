//
//  NSString+Hex.m
//  LuckyPicker
//
//  Created by BangshengXie on 30/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "NSString+Hex.h"


@implementation NSString (Hex)

+ (NSString *)hexStringWithUIColor:(UIColor *)color
{
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r, g, b, a;
    
#warning queer compiler warning about if condition
    //compiler will warning if no initialize
    //it think whenever (colorSpace == kCGColorSpaceModelRGB) condition is false
    r = g = b = a = 0;
    
    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    }
    else if (colorSpace == kCGColorSpaceModelRGB)
    {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
    
    //no need alpha
//    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
//            lroundf(r * 255),
//            lroundf(g * 255),
//            lroundf(b * 255),
//            lroundf(a * 255)];
}

@end
