//
//  PickListViewController.h
//  LuckyPicker
//
//  Created by BangshengXie on 23/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RandomListContent+CoreDataClass.h"
#import "RandomListItem+CoreDataClass.h"

@interface PickListViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedContext;
@property (strong, nonatomic) NSManagedObjectID *randomListContentID;
//@property (assign, nonatomic) NSInteger randomListContentIndex;

@end
