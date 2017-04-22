//
//  AddContentViewController.h
//  LuckyPicker
//
//  Created by BangshengXie on 22/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RandomListContent+CoreDataClass.h"
#import "RandomListItem+CoreDataClass.h"

@interface AddContentViewController : UIViewController

#warning no implement interface
@property (strong, nonatomic) NSString *sayHello;
@property (strong, nonatomic) RandomListContent *randomListContent;
@property (strong, nonatomic) NSManagedObjectContext *managedContext;

@end
