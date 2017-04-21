//
//  RandomListTitle+CoreDataProperties.m
//  LuckyPicker
//
//  Created by BangshengXie on 21/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListTitle+CoreDataProperties.h"

@implementation RandomListTitle (CoreDataProperties)

+ (NSFetchRequest<RandomListTitle *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RandomListTitle"];
}

@dynamic title;
@dynamic contents;

@end
