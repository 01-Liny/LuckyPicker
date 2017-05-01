//
//  PickPasscodeViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 30/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "PickPasscodeViewController.h"
#import "RandomPassword.h"
#import "UIColor+Hex.h"

@interface PickPasscodeViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *pickView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickButton;

@property (weak, nonatomic) IBOutlet UIButton *numberButton;
@property (weak, nonatomic) IBOutlet UIButton *characterButton;

@property (strong, nonatomic) NSTimer *currentTimer;
@property (strong, nonatomic) NSTimer *currentNumberButtonTimer;
@property (strong, nonatomic) NSTimer *currentCharacterButtonTimer;

@property (strong, nonatomic) CAAnimationGroup *showAnimation;
@property (strong, nonatomic) CAAnimationGroup *hideAnimation;

@property (strong, nonatomic) NSMutableArray *lenghtArray;
@property (strong, nonatomic) RandomPassword *randomPasscode;

@property (assign, nonatomic) Boolean isNumber;
@property (assign, nonatomic) Boolean isCharacter;

@end

@implementation PickPasscodeViewController

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

- (NSMutableArray *)lenghtArray
{
    if(!_lenghtArray)
    {
        _lenghtArray = [[NSMutableArray alloc] init];
        for(int i=1; i<=16; i++)
        {
            [_lenghtArray addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _lenghtArray;
}

- (RandomPassword *)randomPasscode
{
    if (!_randomPasscode)
    {
        _randomPasscode = [[RandomPassword alloc] init];
    }
    return _randomPasscode;
}

#pragma mark - view did load

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //颜色统一，stroyboard里的颜色输出跟这里有区别，主要是浮点数的问题
    self.pickView.backgroundColor = [UIColor colorWithHexString:@"#3B577D"];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    self.textLabel.adjustsFontSizeToFitWidth = true;
    
    self.randomPasscode.length = 1;
    self.isCharacter = true;
    self.isNumber = true;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add length label
    UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pickerView.frame.size.width/2+ 20, self.pickerView.frame.size.height / 2 - 51, 100, 100)];
    quantityLabel.font = [UIFont boldSystemFontOfSize:17];
    quantityLabel.textColor = [UIColor colorWithRed:1
                                              green:1
                                               blue:1
                                              alpha:85.0/100];
    quantityLabel.text = @"lenght";
    [self.pickerView addSubview:quantityLabel];
    
    //pickView
    self.pickView.layer.cornerRadius = 10;
    self.pickView.layer.masksToBounds = NO;
    [self addShadow:self.pickView];
    
    //pickButton
    self.pickButton.frame = self.pickView.frame;
    
    //numberButton
    self.numberButton.layer.cornerRadius = 5;
    self.numberButton.layer.masksToBounds = NO;
    [self addShadow:self.numberButton];
    
    //characterButton
    self.characterButton.layer.cornerRadius = 5;
    self.characterButton.layer.masksToBounds = NO;
    [self addShadow:self.characterButton];
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

- (IBAction)pick:(id)sender
{
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
    self.textLabel.numberOfLines = 1;
    
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
    self.randomPasscode.isNumber = self.isNumber;
    self.randomPasscode.isCharacter = self.isCharacter;
    
    NSString *string = [self.randomPasscode generatePassword];
    self.textLabel.text = string;
}


- (IBAction)changeArgument:(UIButton *)sender
{
    if(sender == self.numberButton)
    {
        [self.numberButton.layer addAnimation:self.hideAnimation forKey:nil];
        self.isNumber = self.isNumber ? false : true;
        
        //防止两个按钮都为false
        if(self.isNumber == false && self.isCharacter == false)
            [self changeArgument:self.characterButton];
        
        [self.currentNumberButtonTimer invalidate];//防止多次调用
        self.currentNumberButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                  repeats:false
                                                                    block:^(NSTimer * _Nonnull timer) {
                                                                        [self.numberButton.layer addAnimation:self.showAnimation forKey:nil];
                                                                        [self setNumberButtonText];
                                                                    }];
    }
    else
    {
        [self.characterButton.layer addAnimation:self.hideAnimation forKey:nil];
        self.isCharacter = self.isCharacter ? false : true;
        
        //防止两个按钮都为false
        if(self.isNumber == false && self.isCharacter == false)
            [self changeArgument:self.numberButton];
        
        [self.currentCharacterButtonTimer invalidate];//防止多次调用
        self.currentCharacterButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                        repeats:false
                                                                          block:^(NSTimer * _Nonnull timer) {
                                                                              [self.characterButton.layer addAnimation:self.showAnimation forKey:nil];
                                                                              [self setCharacterButtonText];
                                                                          }];
    }
}

- (void)setNumberButtonText
{
    if(self.isNumber)
    {
        [self.numberButton setTitle:@"Number" forState:UIControlStateNormal];
    }
    else
    {
        [self.numberButton setTitle:@"No Number" forState:UIControlStateNormal];
    }
}

- (void)setCharacterButtonText
{
    if(self.isCharacter)
    {
        [self.characterButton setTitle:@"Letter" forState:UIControlStateNormal];
    }
    else
    {
        [self.characterButton setTitle:@"No Letter" forState:UIControlStateNormal];
    }
}

#pragma mark - <UIPickerViewDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.lenghtArray.count;
}

#pragma mark - <UIPickerViewDelegate>

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *columnView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30,100)];
    columnView.font = [UIFont systemFontOfSize:24];
    columnView.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    columnView.text = self.lenghtArray[row];
    columnView.textAlignment = NSTextAlignmentRight;
    
    return columnView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //pickerView value only from 0 to n
    self.randomPasscode.length = row + 1;
}



@end
