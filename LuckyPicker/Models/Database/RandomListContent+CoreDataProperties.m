//
//  RandomListContent+CoreDataProperties.m
//  LuckyPicker
//
//  Created by BangshengXie on 19/05/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListContent+CoreDataProperties.h"

@implementation RandomListContent (CoreDataProperties)

+ (NSFetchRequest<RandomListContent *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RandomListContent"];
}

@dynamic title;
@dynamic items;

@end
