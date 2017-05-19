//
//  RandomListContent+CoreDataProperties.h
//  LuckyPicker
//
//  Created by BangshengXie on 19/05/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListContent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RandomListContent (CoreDataProperties)

+ (NSFetchRequest<RandomListContent *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) NSSet<RandomListItem *> *items;

@end

@interface RandomListContent (CoreDataGeneratedAccessors)

- (void)addItemsObject:(RandomListItem *)value;
- (void)removeItemsObject:(RandomListItem *)value;
- (void)addItems:(NSSet<RandomListItem *> *)values;
- (void)removeItems:(NSSet<RandomListItem *> *)values;

@end

NS_ASSUME_NONNULL_END
