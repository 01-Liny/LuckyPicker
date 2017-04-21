//
//  RandomListContent+CoreDataProperties.h
//  LuckyPicker
//
//  Created by BangshengXie on 21/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomListContent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RandomListContent (CoreDataProperties)

+ (NSFetchRequest<RandomListContent *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *item;
@property (nullable, nonatomic, retain) RandomListTitle *title;

@end

NS_ASSUME_NONNULL_END
