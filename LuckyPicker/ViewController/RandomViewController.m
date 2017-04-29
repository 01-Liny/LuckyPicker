//
//  RandomViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 20/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomViewController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include "RandomList.h"

@interface RandomViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *uiview;

@property (weak, nonatomic) IBOutlet UIView *pickView;
@property (weak, nonatomic) IBOutlet UIButton *pickButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;

@property (weak, nonatomic) IBOutlet UIButton *repeatButton;

@property (strong, nonatomic) Random *random;
@property (strong, nonatomic) RandomList *randomList;
@property (assign, nonatomic) Boolean isRepeat;
@property (assign, nonatomic) Boolean isNeedRegenerateList;
@property (assign, nonatomic) NSInteger norepeatAmount;
@property (assign, nonatomic) NSMutableArray *tmpNumberList;

@property (strong, nonatomic) NSTimer *currentTimer;
@property (strong, nonatomic) NSTimer *currentButtonTimer;
@property (weak, nonatomic) UITextField *currentTextField;

@property (strong, nonatomic) CAAnimationGroup *showAnimation;
@property (strong, nonatomic) CAAnimationGroup *hideAnimation;

- (UIColor*)colorWithHexString:(NSString*)hexString;
- (void)setup;
- (void)addShadow:(UIView*)view;
- (void)setRepeatButton;
- (void)limitRandomListQuantity;

@end

@implementation RandomViewController

#pragma mark - lazy instantiation

- (Random*)random
{
    if(!_random)
    {
        _random = [[Random alloc] init];
    }
    return _random;
}

- (RandomList*)randomList
{
    if(!_randomList)
    {
        _randomList = [[RandomList alloc] init];
        _randomList.fromValue = [self.fromTextField.text intValue];
        _randomList.toValue = [self.toTextField.text intValue];
        _randomList.quantity = [self.randomList getOffset];
    }
    return _randomList;
}

- (CAAnimationGroup*)showAnimation
{
    if(!_showAnimation)
    {
        CASpringAnimation *expandScale = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
        expandScale.fromValue = [NSNumber numberWithFloat:0.0f];
        expandScale.toValue = [NSNumber numberWithFloat:1.0f];
        
        CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeIn.fromValue = [NSNumber numberWithFloat:0];
        fadeIn.toValue = [NSNumber numberWithFloat:1];
        
        CAAnimationGroup *fadeAndScale = [CAAnimationGroup animation];
        fadeAndScale.animations = @[expandScale, fadeIn];
        fadeAndScale.duration = 0.5;
        fadeAndScale.removedOnCompletion = NO;
        fadeAndScale.fillMode = kCAFillModeForwards;
        
        _showAnimation = fadeAndScale;
        return fadeAndScale;
    }
    return _showAnimation;
}

- (CAAnimationGroup*)hideAnimation
{
    if(!_hideAnimation)
    {
        CABasicAnimation *shrinkScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shrinkScale.fromValue = [NSNumber numberWithFloat:1.0f];
        shrinkScale.toValue = [NSNumber numberWithFloat:0.0f];
        
        CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOut.fromValue = [NSNumber numberWithFloat:1];
        fadeOut.toValue = [NSNumber numberWithFloat:0];
        
        CAAnimationGroup *fadeAndScale = [CAAnimationGroup animation];
        fadeAndScale.animations = @[shrinkScale, fadeOut];
        fadeAndScale.duration = 0.2;
        fadeAndScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        fadeAndScale.removedOnCompletion = NO;
        fadeAndScale.fillMode = kCAFillModeForwards;
        
        _hideAnimation = fadeAndScale;
        return _hideAnimation;
    }
    return _hideAnimation;
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //[self setNeedsStatusBarAppearanceUpdate];
    [self setup];
}

- (void)setup
{
    //norepeatAmount
    self.norepeatAmount = 0;
    
    //isRepeat
    self.isRepeat = true;
    
    //isTextChanged
    self.isNeedRegenerateList = true;
    
    //TextField
    self.fromTextField.delegate = self;
    self.toTextField.delegate = self;
    
    //pickButton
    self.pickButton.frame = self.pickView.frame;
    
    //numberLabel
    self.numberLabel.adjustsFontSizeToFitWidth = YES;
    
    //Keybaoard Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //pickView
    self.pickView.layer.cornerRadius = 10;
    self.pickView.layer.masksToBounds = NO;
    self.pickView.backgroundColor = [self colorWithHexString:@"#3B577D"];
    [self addShadow:self.pickView];
    
    //repeatButton
    self.repeatButton.layer.cornerRadius = 5;
    self.repeatButton.layer.masksToBounds = NO;
    [self addShadow:self.repeatButton];
}

- (void)addShadow:(UIView*)view
{
    CGFloat offset = 300.0/view.bounds.size.height;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowOffset = CGSizeMake(0, 5/offset);
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowPath = shadowPath.CGPath;
    view.layer.shadowRadius = 6/offset;
}

#pragma mark - button event

- (IBAction)setRepeatMode:(id)sender
{
    if(self.isRepeat)
    {
        self.isRepeat = false;
        self.isNeedRegenerateList = true;
        self.norepeatAmount = 0;
    }
    else
    {
        self.isRepeat = true;
    }
    [self.repeatButton.layer addAnimation:self.hideAnimation
                                   forKey:nil];
    [self setRepeatButton];
    //self.showAnimation.beginTime =  0.1;
    [self.currentButtonTimer invalidate];//防止多次调用
    self.currentButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              repeats:false
                                                                block:^(NSTimer * _Nonnull timer) {
                                                                    [self.repeatButton.layer addAnimation:self.showAnimation
                                                                                                   forKey:nil];
                                                                }];
}

- (IBAction)pick:(id)sender
{
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.pickView.backgroundColor = [self colorWithHexString:@"#6983ac"];
                     }completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              self.pickView.backgroundColor = [self colorWithHexString:@"#3B577D"];
                                              
                                          }];
                     }];
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / self.pickView.layer.frame.size.width/2;
    
    [self.numberLabel setFont:[UIFont systemFontOfSize:100]];
    self.numberLabel.text = @"";
    self.numberLabel.numberOfLines = 1;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(perspective, CATransform3DMakeRotation(M_PI, 0, 1, 0))];
    animation.duration = 0.5;
    //animation.beginTime = CACurrentMediaTime();
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.175 :0.885 :0.32 :1.275];
    [self.pickView.layer addAnimation:animation forKey:@"3d"];
    
    [self.currentTimer invalidate];//防止多次调用
    self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:0.35
                                                    repeats:false
                                                      block:^(NSTimer * timer) {
                                                          NSLog(@"Run");
                                                          [UIView transitionWithView:self.numberLabel
                                                                            duration:0.2f
                                                                             options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseIn
                                                                          animations:^{
                                                                              [self generate];
                                                                          } completion:nil];
                                                          
                                                      }];
}

- (void)generate
{
    if(self.randomList.fromValue != [self.fromTextField.text intValue]
       || self.randomList.toValue != [self.toTextField.text intValue])
    {
        self.randomList.fromValue = [self.fromTextField.text intValue];
        self.randomList.toValue = [self.toTextField.text intValue];
        self.randomList.quantity = [self.randomList getOffset];
        if(self.isRepeat  == false)
            self.isNeedRegenerateList = true;
    }

    if(self.isRepeat)
    {
        self.numberLabel.text = [NSString stringWithFormat:@"%d",[self.randomList generate]];
    }
    else
    {
        [self limitRandomListQuantity];
        if(self.isNeedRegenerateList || self.tmpNumberList.count == 0)
        {
            self.isNeedRegenerateList = false;
            self.tmpNumberList = [self.randomList generateList];
            self.norepeatAmount = 0;
        }
        self.random.toValue = [self.randomList getOffset] - (int32_t)self.norepeatAmount - 1;
        NSInteger tmpIndex = [self.random generate];
        self.norepeatAmount++;
        self.numberLabel.text = [self.tmpNumberList objectAtIndex:tmpIndex];
        [self.tmpNumberList removeObjectAtIndex:tmpIndex];
        
        [self setRepeatButton];
    }
    
}

#pragma mark - keyboard notification event

// 键盘弹出时
-(void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD，如果需要的话)
    CGFloat offset = (self.currentTextField.frame.origin.y+self.currentTextField.frame.size.height+0) - (self.uiview.frame.size.height - kbHeight);
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.uiview.frame = CGRectMake(0.0f, -offset, self.uiview.frame.size.width, self.uiview.frame.size.height);
        }];
    }
}

//键盘消失时
-(void)keyboardWillHidden:(NSNotification*)notification
{
    // 键盘动画时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.uiview.frame = CGRectMake(0, 0, self.uiview.frame.size.width, self.uiview.frame.size.height);
    }];
    
    //fromValue and toValue will be setted immediately after keyboard disappear
    if(self.randomList.fromValue != [self.fromTextField.text intValue]
       || self.randomList.toValue != [self.toTextField.text intValue])
    {
        self.randomList.fromValue = [self.fromTextField.text intValue];
        self.randomList.toValue = [self.toTextField.text intValue];
        self.randomList.quantity = [self.randomList getOffset];
        
        if(self.isRepeat  == false)
        {
            [self limitRandomListQuantity];
            self.isNeedRegenerateList = true;
            self.norepeatAmount = 0;
            [self setRepeatButton];
        }
    }
}

#pragma mark - touch event

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    NSLog(@"touch");
}

#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.currentTextField = nil;
}

#pragma mark - generic method

- (void)setRepeatButton
{
    UIColor *tmpColor = [UIColor colorWithRed:0
                                        green:0
                                         blue:0
                                        alpha:0.64];
    NSMutableAttributedString *tmpString;
    
    if(self.isRepeat)
    {
        tmpString = [[NSMutableAttributedString alloc] initWithString:@"Repeat"];
        [tmpString addAttribute:NSForegroundColorAttributeName
                          value:tmpColor
                          range:NSMakeRange(0, tmpString.length)];
    }
    else
    {
        [self limitRandomListQuantity];
        
        tmpString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"No Repeat\n%ld / %d", self.norepeatAmount, [self.randomList getOffset]]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        [tmpString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, tmpString.length)];
        [tmpString addAttribute:NSForegroundColorAttributeName
                          value:tmpColor
                          range:NSMakeRange(0, tmpString.length)];
    }
    [self.repeatButton setAttributedTitle:tmpString forState:UIControlStateNormal];
}

- (void)limitRandomListQuantity
{
    //limite max quantity 100000
    if(self.randomList.quantity > 100000)
    {
        if(self.randomList.fromValue <= self.randomList.toValue)
        {
            self.randomList.toValue = self.randomList.fromValue + 99999;
            [self.toTextField setText:[NSString stringWithFormat:@"%d", self.randomList.toValue]];
        }
        else
        {
            self.randomList.fromValue = self.randomList.toValue + 99999;
            [self.fromTextField setText:[NSString stringWithFormat:@"%d", self.randomList.fromValue]];
        }
        self.randomList.quantity = 100000;
    }
}

- (UIColor*)colorWithHexString:(NSString*)hexString
{
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
