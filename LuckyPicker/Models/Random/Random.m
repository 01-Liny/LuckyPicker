//
//  Random.m
//  LuckyPicker
//
//  Created by BangshengXie on 17/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "Random.h"

@implementation Random

#pragma mark - init

- (id)init
{
    self = [super init];
    if(self)
    {
        self.fromValue = 0;
        self.toValue = 0;
    }
    return self;
}

#pragma mark - get offset

- (int32_t)getOffset
{
    return abs(self.toValue - self.fromValue) +1;
}

#pragma mark - generate

- (int32_t)generate
{
    if(self.toValue >= self.fromValue)
    {
        return self.fromValue + (arc4random_uniform(self.toValue - self.fromValue +1));
    }
    else
    {
        return self.toValue + (arc4random_uniform(self.fromValue - self.toValue +1));
    }
}

@end
