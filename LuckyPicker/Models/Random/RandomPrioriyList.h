//
//  RandomPrioriyList.h
//  LuckyPicker
//
//  Created by BangshengXie on 18/05/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomPrioriyList : NSObject

@property (assign, nonatomic) NSInteger quantity;

- (void)setPriorityList:(NSMutableArray*) priorityList;
- (NSMutableArray*)generateList;

@end
