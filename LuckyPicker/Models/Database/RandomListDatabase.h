//
//  RandomListDatabase.h
//  LuckyPicker
//
//  Created by BangshengXie on 22/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RandomListDatabase : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

@end
