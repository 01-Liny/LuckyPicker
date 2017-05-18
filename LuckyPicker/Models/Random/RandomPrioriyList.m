//
//  RandomPrioriyList.m
//  LuckyPicker
//
//  Created by BangshengXie on 18/05/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomPrioriyList.h"
#import "Random.h"

@interface RandomPrioriyList()

@property (strong, nonatomic) NSMutableArray* priorityAppendList;
@property (strong, nonatomic) Random* random;
@property (assign, nonatomic) NSInteger prioritySum;

@end

@implementation RandomPrioriyList

#pragma mark - lazy instantiation

- (NSMutableArray *)priorityAppendList
{
    if(!_priorityAppendList)
    {
        _priorityAppendList = [[NSMutableArray alloc] init];
    }
    return _priorityAppendList;
}

- (Random *)random
{
    if(!_random)
    {
        _random = [[Random alloc] init];
        _random.fromValue = 1;
    }
    return _random;
}

#pragma mark - init

- (id)init
{
    self = [super init];

    return self;
}

#pragma mark - set priority list

- (void)setPriorityList:(NSMutableArray *)priorityList
{
    //ensure empty list
    [self.priorityAppendList removeAllObjects];
    
    int appendValue = 0;
    NSString *string;
    for (int i = 0; i < priorityList.count; i++)
    {
        string = priorityList[i];
        appendValue += [string integerValue];
        
        [self.priorityAppendList addObject:[NSString stringWithFormat:@"%d", appendValue]];
    }
    
    self.prioritySum = appendValue;
}

#pragma mark - generate list

- (NSMutableArray *)generateList
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *string;
    
    self.random.toValue = (int32_t)self.prioritySum;
    
    //duplicate prioriyAppendList
    NSMutableArray *tmpPriorityAppendList = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.priorityAppendList.count; i++)
    {
        [tmpPriorityAppendList addObject:self.priorityAppendList[i]];
    }
    
    //index list
    NSMutableArray *tmpIndexList = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.priorityAppendList.count; i++)
    {
        [tmpIndexList addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    NSInteger minusValue = 0;
    while (result.count < self.quantity)
    {
        NSInteger randomNumber = [self.random generate];
        
        int index = 0;
        while (index < tmpPriorityAppendList.count)
        {
            string = tmpPriorityAppendList[index];
            NSInteger tmp = [string integerValue];
            
            if(tmp >= randomNumber)
            {
                self.random.toValue -= (int32_t)tmp;
                //not the first one
                if(index!=0)
                {
                    string = tmpPriorityAppendList[index -1];
                    NSInteger lastValue = [string integerValue];
                    minusValue = tmp - lastValue;
                }
                else
                    minusValue = tmp;
                break;
            }
            else
                index++;
        }
        
        [result addObject:tmpIndexList[index]];
        
        [tmpIndexList removeObjectAtIndex:index];
        [tmpPriorityAppendList removeObjectAtIndex:index];
        
        while (index < tmpPriorityAppendList.count)
        {
            string = tmpPriorityAppendList[index];
            NSInteger tmp = [string integerValue];
            tmp -= minusValue;
            tmpPriorityAppendList[index] = [NSString stringWithFormat:@"%ld", tmp];
            index++;
        }
    }
    
    return result;
}

@end
