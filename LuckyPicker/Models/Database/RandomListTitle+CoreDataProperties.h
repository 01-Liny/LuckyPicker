//
//  RandomListTitle+CoreDataProperties.h
//  LuckyPicker
//
//  Created by BangshengXie on 21/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListTitle+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RandomListTitle (CoreDataProperties)

+ (NSFetchRequest<RandomListTitle *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) NSSet<RandomListContent *> *contents;

@end

@interface RandomListTitle (CoreDataGeneratedAccessors)

- (void)addContentsObject:(RandomListContent *)value;
- (void)removeContentsObject:(RandomListContent *)value;
- (void)addContents:(NSSet<RandomListContent *> *)values;
- (void)removeContents:(NSSet<RandomListContent *> *)values;

@end

NS_ASSUME_NONNULL_END
