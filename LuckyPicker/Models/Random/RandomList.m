//
//  RandomList.m
//  LuckyPicker
//
//  Created by BangshengXie on 17/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomList.h"

@interface RandomList()

@property (strong, nonatomic) NSMutableArray *list;

@end

@implementation RandomList

#pragma mark - lazy instantiation

- (NSMutableArray*)list
{
    if(!_list)
    {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (void)setQuantity:(NSInteger)quantity
{
    NSInteger offset = abs(self.fromValue - self.toValue) + 1;
    if(quantity > offset)
        _quantity = offset;//prevent quantity bigger than offset

    else
        _quantity = quantity;
}

#pragma mark - init

- (id)init
{
    self = [super init];
    if(self)
    {
        self.quantity = 0;
    }
    return self;
}

#pragma mark - generate

- (NSMutableArray*)generateList
{
    //ensure empty list
    [self.list removeAllObjects];
    
    NSMutableArray *tmpList = [[NSMutableArray alloc] initWithCapacity:self.quantity];
    if(self.fromValue <= self.toValue)
    {
        for(int32_t i=self.fromValue; i<=self.toValue; i++)
        {
            [tmpList addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    else
    {
        for(int32_t i=self.toValue; i<=self.fromValue; i++)
        {
            [tmpList addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    
    Random *tmpRandom = [[Random alloc] init];
    tmpRandom.toValue = (int32_t)self.quantity - 1;
    
    NSInteger randomNumber;
    while (self.list.count < self.quantity)
    {
        randomNumber = [tmpRandom generate];
        [self.list addObject:[tmpList objectAtIndex:randomNumber]];
        
        [tmpList removeObjectAtIndex:randomNumber];
        tmpRandom.toValue--;
    }
    
    return self.list;
}

@end
