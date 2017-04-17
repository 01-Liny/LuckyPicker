//
//  RandomPassword.h
//  LuckyPicker
//
//  Created by BangshengXie on 18/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomPassword : NSObject

@property (assign, nonatomic) NSInteger length;
@property (assign, nonatomic) Boolean isNumber;
@property (assign, nonatomic) Boolean isCharacter;

- (id)init;
- (NSString*)generatePassword;

@end
