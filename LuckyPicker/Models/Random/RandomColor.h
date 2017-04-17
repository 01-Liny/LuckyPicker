//
//  RandomColor.h
//  LuckyPicker
//
//  Created by BangshengXie on 19/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RandomColor : NSObject

- (id)init;
- (UIColor*)generateColor;
- (NSDictionary*)generateMaterialColor;

@end
