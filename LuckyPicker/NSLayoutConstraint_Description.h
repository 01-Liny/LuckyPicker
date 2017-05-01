//
//  NSLayoutConstraint_Description.h
//  LuckyPicker
//
//  Created by BangshengXie on 01/05/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end
