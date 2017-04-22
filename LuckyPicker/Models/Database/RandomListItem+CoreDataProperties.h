//
//  RandomListItem+CoreDataProperties.h
//  LuckyPicker
//
//  Created by BangshengXie on 22/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RandomListItem (CoreDataProperties)

+ (NSFetchRequest<RandomListItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) RandomListContent *title;

@end

NS_ASSUME_NONNULL_END
