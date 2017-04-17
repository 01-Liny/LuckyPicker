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

- (NSArray*)generateList
{
    //ensure empty list
    [self.list removeAllObjects];
    
    NSInteger randomNumber;
    while (self.list.count < self.quantity)
    {
        randomNumber = [self generate];
        if(![self.list containsObject:[NSString stringWithFormat:@"%ld", randomNumber]])
        {
            [self.list addObject:[NSString stringWithFormat:@"%ld", randomNumber]];
        }
    }
    
    return [self.list copy];
}

@end
