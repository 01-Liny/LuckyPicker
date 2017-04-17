//
//  RandomColor.m
//  LuckyPicker
//
//  Created by BangshengXie on 19/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomColor.h"

@interface RandomColor()

@property (strong, nonatomic) NSMutableArray *materialColorList;

@end

@implementation RandomColor

#pragma mark - lazy instantiation

- (NSMutableArray*)materialColorList
{
    if(!_materialColorList)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MaterialColor" ofType:@"json"];
        NSData *data=[NSData dataWithContentsOfFile:path];
        
        NSError *error;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
        if(error)
            NSLog(@"%@",error);
        NSLog(@"%@", result);
        _materialColorList = [result objectForKey:@"MaterialColor"];
    }
    return _materialColorList;
}

#pragma mark - init

- (id)init
{
    self = [super init];
    return self;
}

#pragma mark - generate

- (UIColor*)generateColor
{
    CGFloat hue = ( arc4random_uniform(256) / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random_uniform(128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random_uniform(128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (NSDictionary*)generateMaterialColor
{
    int32_t length = (int32_t)self.materialColorList.count;
    
    return [self.materialColorList objectAtIndex:arc4random_uniform(length)];
}

@end
