//
//  Random.h
//  LuckyPicker
//
//  Created by BangshengXie on 17/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Random : NSObject

@property (assign, nonatomic) int32_t fromValue;
@property (assign, nonatomic) int32_t toValue;

- (id)init;
- (int32_t)generate;

@end
