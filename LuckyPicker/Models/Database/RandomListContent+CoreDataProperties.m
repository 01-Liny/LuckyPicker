//
//  RandomListContent+CoreDataProperties.m
//  LuckyPicker
//
//  Created by BangshengXie on 21/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListContent+CoreDataProperties.h"

@implementation RandomListContent (CoreDataProperties)

+ (NSFetchRequest<RandomListContent *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RandomListContent"];
}

@dynamic item;
@dynamic title;

@end
