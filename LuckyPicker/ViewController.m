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
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) RandomColor *random;

@property (strong, nonatomic) NSTimer *curTimer;

@property (strong, nonatomic) NSMutableArray *uiviewArray;
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSMutableArray *currentTimerArray;

@property (strong, nonatomic) CAAnimationGroup *showAnimation;
@property (strong, nonatomic) CAAnimationGroup *hideAnimation;

- (UIColor*)colorWithHexcode:(int32_t)hexcode;
- (UIColor*)colorWithHexString:(NSString*)hexString;

@end

@implementation ViewController

- (NSMutableArray *)currentTimerArray
{
    if(!_currentTimerArray || _currentTimerArray.count == 0)//why???
    {
        _currentTimerArray = [[NSMutableArray alloc] init];
    }
    return _currentTimerArray;
}

- (CAAnimationGroup*)showAnimation
{
    if(!_showAnimation)
    {
        CASpringAnimation *expandScale = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
        expandScale.fromValue = [NSNumber numberWithFloat:0.0f];
        expandScale.toValue = [NSNumber numberWithFloat:0.92f];
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.random = [[RandomColor alloc] init];
    //self.button.backgroundColor= [UIColor blackColor];
    //self.button.imageView.image = [UIImage imageNamed:@"Add"];

    [self setup];
}

- (void)setup
{
    self.uiviewArray = [[NSMutableArray alloc] init];
    self.buttonArray = [[NSMutableArray alloc] init];
    
    NSInteger maxColumn = 3;
    NSInteger quantity = 9;
    
    CGFloat width = (self.uiview.frame.size.width -(maxColumn-1)*10)/ maxColumn;
    for (int i = 0; i < quantity; i++)
    {
        CGFloat x = (i %maxColumn)*(width+10);
        CGFloat y = (i/ maxColumn)*(width + 10);
        if(i+1==quantity)//the last one
        {
            if(x==0)
            {
                x = width/2;
            }
        }
        NSLog(@"x y:%f %f",x,y);
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, width)];
        tmpView.backgroundColor = [UIColor blueColor];
        UIButton *tmpButton = [[UIButton alloc] initWithFrame:tmpView.frame];
        
        //渲染图片时用
        //tmpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        //tmpButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        
        tmpButton.titleLabel.adjustsFontSizeToFitWidth = true;
        [tmpButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [tmpView addSubview:tmpButton];
        [self.uiview addSubview:tmpView];
        
        [self.uiviewArray addObject:tmpView];
        [self.buttonArray addObject:tmpButton];
    }
}

- (void)buttonPress:(UIButton*)sender
{
    UIView *tmpUiView = sender.superview;
        [UIView animateWithDuration:0.1
                         animations:^{
                             tmpUiView.backgroundColor = [self colorWithHexString:@"69DBFF"];
                         }completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5
                                              animations:^{
                                                  tmpUiView.backgroundColor = [self colorWithHexString:@"279CEB"];
    
                                              }];
                         }];
    
        CATransform3D perspective = CATransform3DIdentity;
        perspective.m34 = -1.0 / self.uiview.layer.frame.size.width/2;
    
    [sender setTitle:@"" forState:UIControlStateNormal];
    [sender setImage:nil forState:UIControlStateNormal];
    
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 0)];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(perspective, CATransform3DMakeRotation(M_PI, 0, 1, 0))];
        animation.duration = 0.5;
        //animation.beginTime = CACurrentMediaTime();
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.175 :0.885 :0.32 :1.275];
        [tmpUiView.layer addAnimation:animation forKey:nil];
    
    NSInteger index = [self.buttonArray indexOfObject:sender];
    NSTimer *currentTimer;
    if(self.currentTimerArray.count > index)
    {
        currentTimer = self.currentTimerArray[index];
        [currentTimer invalidate];//防止多次调用
    }
    self.currentTimerArray[index] =[NSTimer scheduledTimerWithTimeInterval:0.35
                                                                   repeats:false
                                                                     block:^(NSTimer * timer)
                                                                    {
                                                                         NSLog(@"Run");
                                                                         [UIView transitionWithView:sender
                                                                                           duration:0.2f
                                                                                            options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseIn
                                                                                         animations:^{
                                                                                             //i have no idead with font size problem,so...
                                                                                             if(sender.bounds.size.width<100)
                                                                                                 sender.titleLabel.font = [UIFont systemFontOfSize:60];
                                                                                             else
                                                                                                 sender.titleLabel.font = [UIFont systemFontOfSize:100];
                                                                                             
                                                                                             [sender setTitle:[NSString stringWithFormat:@"%d", arc4random()%7] forState:UIControlStateNormal];
                                                                                             sender.titleLabel.adjustsFontSizeToFitWidth = true;
                                                                                            
                                                                                             
                                                                                             //[sender setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
                                                                                             ////sender.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                                                                             //sender.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                                                                                         } completion:nil];
                                                                         
                                                                     }];
    
}

- (void)resetPickView:(NSInteger)quantity
{
    NSInteger maxColumn;
    maxColumn = quantity <= 4 ? 2 : 3;
    maxColumn = quantity == 1 ? 1 : maxColumn;
    
    CGFloat width = (self.uiview.frame.size.width -(maxColumn-1)*10)/ maxColumn;
    NSLog(@"width: %f",width);
    for (int i = 0; i < self.uiviewArray.count; i++)
    {
        NSLog(@"%ld",self.buttonArray.count);
        UIView *tmpView = [self.uiviewArray objectAtIndex:i];
        UIButton *tmpButton = [self.buttonArray objectAtIndex:i];
        if(i < quantity)
        {
            CGFloat x = (i % maxColumn)*(width + 10);
            CGFloat y = (i / maxColumn)*(width + 10);
            if(i+1==quantity)//the last one
            {
                if(x==0)
                {
                    x = width/2;
                }
            }
            NSLog(@"x: %f y: %f",x,y);
            tmpView.hidden = false;
            tmpView.frame = CGRectMake(x, y, width, width);
            tmpButton.frame = tmpView.bounds;
            
            [tmpView.layer addAnimation:self.hideAnimation forKey:nil];
            
            NSTimer *currentTimer;
            if(self.currentTimerArray.count > i)
            {
                currentTimer = self.currentTimerArray[i];
                [currentTimer invalidate];//防止多次调用
            }
        
            currentTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                           repeats:false
                                                             block:^(NSTimer * timer) {
                                                                 [tmpView.layer addAnimation:self.showAnimation forKey:nil];
                                                                 NSLog(@"Timer");
                                                              }];
            //[self.currentTimerArray insertObject:currentTimer atIndex:i];
            self.currentTimerArray[i] = currentTimer;
        }
        else
        {
            [tmpView.layer addAnimation:self.hideAnimation forKey:nil];
            tmpView.hidden = true;
        }
    }
    
//    for (int i = 0; i < quantity; i++)
//    {
//        CGFloat x = (i %maxColumn)*(width+10);
//        CGFloat y = (i/ maxColumn)*(width + 10);
//        if(i+1==quantity)//the last one
//        {
//            if(x==0)
//            {
//                x = width/2;
//            }
//        }
//        NSLog(@"x y:%f %f",x,y);
//        
//        
//        
//        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, width)];
//        tmpView.backgroundColor = [UIColor blueColor];
//        UIButton *tmpButton = [[UIButton alloc] initWithFrame:tmpView.frame];
//        [tmpView addSubview:tmpButton];
//        [self.uiview addSubview:tmpView];
//        
//        [self.uiviewArray addObject:tmpView];
//        [self.buttonArray addObject:tmpButton];
//    }
}

- (void)flipAnimation:(UIView*)uiview text:(NSString*)string
{
    
}

- (IBAction)button:(id)sender
{
    NSInteger quantity = [self.textField.text integerValue];
    [self resetPickView:quantity];
    
//    [UIView animateWithDuration:0.1
//                     animations:^{
//                         self.newview.backgroundColor = [self colorWithHexString:@"69DBFF"];
//                     }completion:^(BOOL finished) {
//                         [UIView animateWithDuration:0.5
//                                          animations:^{
//                                              self.newview.backgroundColor = [self colorWithHexString:@"279CEB"];
//                                              
//                                          }];
//                     }];
//    
//    CATransform3D perspective = CATransform3DIdentity;
//    perspective.m34 = -1.0 / self.uiview.layer.frame.size.width/2;
//    
//    self.button.imageView.image =nil;
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 0)];
//    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(perspective, CATransform3DMakeRotation(M_PI, 0, 1, 0))];
//    animation.duration = 0.5;
//    //animation.beginTime = CACurrentMediaTime();
//    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.175 :0.885 :0.32 :1.275];
//    [self.newview.layer addAnimation:animation forKey:@"3d1"];
//    
//    [self.curTimer invalidate];//防止多次调用
//    self.curTimer = [NSTimer scheduledTimerWithTimeInterval:0.35
//                                                    repeats:false
//                                                      block:^(NSTimer * timer) {
//                                                          NSLog(@"Run");
//                                                          [UIView transitionWithView:self.button
//                                                                            duration:0.2f
//                                                                             options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseIn
//                                                                          animations:^{
//                                                                              self.button.imageView.image = [UIImage imageNamed:@"add"];
//                                                                          } completion:nil];
//                                                          
//                                                      }];
}

- (IBAction)flip:(id)sender
{
//    [UIView animateWithDuration:0.1
//                     animations:^{
//                         self.imageView.backgroundColor = [self colorWithHexString:@"69DBFF"];
//                     }completion:^(BOOL finished) {
//                         [UIView animateWithDuration:0.5
//                                          animations:^{
//                                              self.imageView.backgroundColor = [self colorWithHexString:@"279CEB"];
//                                              
//                                          }];
//                     }];
//    
//    [self.imageView setImage:nil];
//    [UIView transitionWithView:self.imageView
//                      duration:0.5f
//                       options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseIn
//                    animations:^{
//                        [self.imageView setImage:[UIImage imageNamed:@"list"]];
//                    } completion:nil];
//        [UIView animateWithDuration:0.5
//                              delay:0
//             usingSpringWithDamping:0.7
//              initialSpringVelocity:0.7
//                            options:UIViewAnimationOptionTransitionFlipFromRight + UIViewAnimationOptionCurveEaseIn
//                         animations:^{
//
//                             self.imageView.transform = CGAffineTransformIdentity;
//                             [self.imageView setImage:[UIImage imageNamed:@"list"]];
//    
//                        } completion:^(BOOL completed){
//                         }];
    
    
//    [self.imageView setImage:[UIImage imageNamed:@"list"]];
//    CATransform3D perspective = CATransform3DIdentity;
//    perspective.m34 = -1.0 / self.uiview.layer.frame.size.width/2;
//    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 0)];
//    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(perspective, CATransform3DMakeRotation(M_PI, 0, 1, 0))];
//    animation.duration = 0.5;
//    //animation.beginTime = CACurrentMediaTime();
//    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.175 :0.885 :0.32 :1.275];
//    [self.imageView.layer addAnimation:animation forKey:@"3d1"];
//
    [self.curTimer invalidate];//防止多次调用
    self.curTimer = [NSTimer scheduledTimerWithTimeInterval:0.35
                                                    repeats:false
                                                      block:^(NSTimer * timer) {
                                                          NSLog(@"Run");

                                                          
                                                      }];
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
