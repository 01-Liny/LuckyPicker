//
//  PickColorViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 30/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "PickColorViewController.h"
#import "RandomColor.h"
#import "UIColor+Hex.h"
#import "NSString+Hex.h"
#import "UIView+BSXMaterialAnimation.h"
#import "IdentifierAvailability.h"

@interface PickColorViewController ()

@property (strong, nonatomic) IBOutlet UIView *uiview;

@property (weak, nonatomic) IBOutlet UIButton *normalButton;

@property (weak, nonatomic) IBOutlet UIButton *pickButton;
@property (weak, nonatomic) IBOutlet UIView *pickView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (strong, nonatomic) CAAnimationGroup *showAnimation;
@property (strong, nonatomic) CAAnimationGroup *hideAnimation;

@property (strong, nonatomic) RandomColor *randomColor;

@property (strong, nonatomic) NSTimer *currentTimer;
@property (strong, nonatomic) NSTimer *currentButtonTimer;

@property (assign, nonatomic) Boolean isNormalColor;
@property (assign, nonatomic) Boolean isAnimating;

@end

@implementation PickColorViewController

#pragma mark - lazy instantiation

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

- (RandomColor *)randomColor
{
    if(!_randomColor)
    {
        _randomColor = [[RandomColor alloc] init];
    }
    return _randomColor;
}

#pragma mark - view did load

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNormalColor = true;
    self.isAnimating = false;
    
    [self setNormalButtonText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //uiview
    [self.uiview setupForBSXAnimation];
    
    //pickButton
    self.pickButton.frame = self.pickView.frame;
    
    //pickView
    self.pickView.layer.cornerRadius = 10;
    self.pickView.layer.masksToBounds = NO;
    self.pickView.backgroundColor = [UIColor colorWithHexString:@"#3B577D"];
    [self addShadow:self.pickView];
    
    //normalButton
    self.normalButton.layer.cornerRadius = 5;
    self.normalButton.layer.masksToBounds = NO;
    [self addShadow:self.normalButton];
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
- (IBAction)setColorMode:(id)sender
{
    self.isNormalColor = self.isNormalColor ? false : true;
    [self.normalButton.layer addAnimation:self.hideAnimation forKey:nil];
    
    [self.currentButtonTimer invalidate];//防止多次调用
    self.currentButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              repeats:false
                                                                block:^(NSTimer * _Nonnull timer) {
                                                                    [self.normalButton.layer addAnimation:self.showAnimation forKey:nil];
                                                                    [self setNormalButtonText];
                                                                }];
}

- (void)setNormalButtonText
{
    UIColor *tmpColor = [UIColor colorWithRed:0
                                        green:0
                                         blue:0
                                        alpha:0.64];
    NSMutableAttributedString *string;
    if(self.isNormalColor)
    {
        string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"normal", nil)];
    }
    else
    {
        string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"material", nil)];
    }
    [string addAttribute:NSForegroundColorAttributeName
                      value:tmpColor
                      range:NSMakeRange(0, string.length)];
    
    [self.normalButton setAttributedTitle:string forState:UIControlStateNormal];
}

- (IBAction)pick:(id)sender
{
    if(self.isAnimating)
        return;
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.pickView.backgroundColor = [UIColor colorWithHexString:@"#6983ac"];
                     }completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              self.pickView.backgroundColor = [UIColor colorWithHexString:@"#3B577D"];
                                              
                                          }];
                     }];
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / self.pickView.layer.frame.size.width/2;
    
    self.textLabel.text = @"";
    
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
                                                              [UIView transitionWithView:self.textLabel
                                                                                duration:0.2f
                                                                                 options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseIn
                                                                              animations:^{
                                                                                  [self generate];
                                                                              } completion:nil];
                                                              
                                                          }];
}

- (void)generate
{
    self.isAnimating = true;
    
    UIColor *color;
    NSString *hexString;
    NSString *colorName;
    
    if(self.isNormalColor)
    {
        color = [self.randomColor generateColor];
        hexString = [NSString hexStringWithUIColor:color];
        
    }
    else
    {
        NSDictionary *dic = [self.randomColor generateMaterialColor];
        color = [UIColor colorWithHexString:[dic objectForKey:MaterialColorValueKey]];
        hexString = [dic objectForKey:MaterialColorValueKey];
        colorName = [dic objectForKey:MaterialColorNameKey];
    }
    
    CGFloat r, g, b, a;
#warning queer compiler warning about if condition
    //compiler will warning if no initialize
    //it think whenever (colorSpace == kCGColorSpaceModelRGB) condition is false
    r = g = b = a = 0;
    
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    }
    else if (colorSpace == kCGColorSpaceModelRGB)
    {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
#warning stupid code
    if(self.isNormalColor)
    {
        self.textLabel.numberOfLines = 2;
        self.textLabel.text = [NSString stringWithFormat:@"R:%ld G:%ld B:%ld\nHex: %@",
                               lroundf(r * 255),
                               lroundf(g * 255),
                               lroundf(b * 255),
                               hexString];
    }
    else
    {
        self.textLabel.numberOfLines = 4;
        self.textLabel.text = [NSString stringWithFormat:@"%@\n\nR:%ld G:%ld B:%ld\nHex: %@",
                               colorName,
                               lroundf(r * 255),
                               lroundf(g * 255),
                               lroundf(b * 255),
                               hexString];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                    repeats:false
                                      block:^(NSTimer * _Nonnull timer) {
                                          [self.uiview runBSXAnimateWithCGPoint:CGPointMake(self.uiview.frame.size.width/2.0, self.uiview.frame.size.height/2.0)
                                                                backgroundColor:color
                                                                       isExpand:true
                                                                       duration:0.65
                                                                 timingFunction:nil
                                                                     completion:^()
                                           {
                                               self.isAnimating = false;
                                           }];
                                      }];
}

@end
