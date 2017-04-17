//
//  ViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 12/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "ViewController.h"
#import "Random.h"
#import "RandomList.h"
#import "RandomPassword.h"
#import "RandomColor.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) IBOutlet UIView *uiview;
@property (strong, nonatomic) RandomColor *random;

- (UIColor*)colorWithHexcode:(int32_t)hexcode;
- (UIColor*)colorWithHexString:(NSString*)hexString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.random = [[RandomColor alloc] init];
    

}

- (IBAction)press:(UIButton *)sender
{
    NSDictionary *materialColor = [self.random generateMaterialColor];
    self.uiview.backgroundColor = [self colorWithHexString:[materialColor valueForKey:@"ColorValue"]];
    self.label.text = [materialColor valueForKey:@"ColorName"];
}

- (UIColor*)colorWithHexcode:(int32_t)hexcode
{
    return [UIColor colorWithRed:((CGFloat)((hexcode & 0xFF0000) >> 16 ))/255.0
                    green:((CGFloat)((hexcode & 0x00FF00) >> 8 ))/255.0
                     blue:((CGFloat)((hexcode & 0x0000FF) >> 0 ))/255.0
                           alpha:1.0];
}

- (UIColor*)colorWithHexString:(NSString*)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
