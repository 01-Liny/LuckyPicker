//
//  RandomListItem+CoreDataProperties.m
//  LuckyPicker
//
//  Created by BangshengXie on 22/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListItem+CoreDataProperties.h"

@implementation RandomListItem (CoreDataProperties)

+ (NSFetchRequest<RandomListItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RandomListItem"];
}

@dynamic name;
@dynamic title;

@end
