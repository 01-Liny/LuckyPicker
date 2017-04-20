//
//  RandomList.h
//  LuckyPicker
//
//  Created by BangshengXie on 17/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "Random.h"

@interface RandomList : Random

@property (assign, nonatomic) NSInteger quantity;

- (id)init;
- (NSMutableArray*)generateList;

@end
