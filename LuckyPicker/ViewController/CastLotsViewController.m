//
//  CastLotsViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 29/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "CastLotsViewController.h"
#import "RandomList.h"

typedef NS_ENUM(NSInteger, ViewStatus)
{
    ViewStatusFliped,
    ViewStatusCorrect,
    ViewStatusWrong,
    ViewStatusQuestion
};

@interface CastLotsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *pickButton;

@property (weak, nonatomic) IBOutlet UIView *diceView;
@property (weak, nonatomic) IBOutlet UILabel *annotationLabel;

@property (strong, nonatomic) NSMutableArray *quantityMutableArray;
@property (strong, nonatomic) NSMutableArray *numberMutableArray;


@property (strong, nonatomic) CAAnimationGroup *showAnimation;
@property (strong, nonatomic) CAAnimationGroup *hideAnimation;

//Dice
@property (strong, nonatomic) NSMutableArray *uiviewArray;
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSMutableArray *currentTimerArray;

@property (assign, nonatomic) NSInteger quantity;//self.random.toValue的缩写
@property (assign, nonatomic) NSInteger lastQuantity;

@property (strong, nonatomic) RandomList *random;
@property (strong, nonatomic) NSMutableArray *randomResultArray;
@property (strong, nonatomic) NSMutableArray *buttonStatusArray;

@property (assign, nonatomic) Boolean isPicking;//记录是否正在处于Pick按钮触发的动画中，这样多次按下Pick按钮，也只会生成一次

@end

@implementation CastLotsViewController

#pragma mark - lazy instantiation

- (NSInteger)quantity
{
    return self.random.toValue;
}

- (void)setQuantity:(NSInteger)quantity
{
    self.random.toValue = (int32_t)quantity;
}

- (NSMutableArray *)currentTimerArray
{
    if(!_currentTimerArray || _currentTimerArray.count == 0)//why _currentTimerArray.count is not nil ???
    {
        _currentTimerArray = [[NSMutableArray alloc] init];
    }
    return _currentTimerArray;
}

- (NSMutableArray *)quantityMutableArray
{
    if(!_quantityMutableArray)
    {
        _quantityMutableArray = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 9; i++)
        {
            [_quantityMutableArray addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _quantityMutableArray;
}

- (NSMutableArray *)numberMutableArray
{
    if(!_numberMutableArray)
    {
        _numberMutableArray = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 9; i++)
        {
            [_numberMutableArray addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _numberMutableArray;
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

- (Random *)random
{
    if(!_random)
    {
        _random = [[RandomList alloc] init];
        _random.fromValue = 1;
    }
    return _random;
}

- (NSMutableArray *)randomResultArray
{
    if(_randomResultArray)
    {
        _randomResultArray = [self.random generateList];
        
    }
    return _randomResultArray;
}

- (NSMutableArray *)buttonStatusArray
{
    if(!_buttonStatusArray)
    {
        _buttonStatusArray = [[NSMutableArray alloc] init];
        for(int i=0; i<9 ;i++)
        {
            [_buttonStatusArray addObject:[NSNumber numberWithInteger:ViewStatusQuestion]];
        }
    }
    return _buttonStatusArray;
}

#pragma mark - view did load

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    self.lastQuantity = 0;//make first time different
    
    [self setup];
    
    //select item when start
    [self.pickerView selectRow:8 inComponent:0 animated:true];
    [self.pickerView selectRow:0 inComponent:1 animated:true];
    
    self.quantity = 9;
    self.random.quantity = 1;
    
    self.isPicking = false;
    
    self.diceView.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //pickButton add shadow
    [self addShadow:self.pickButton];
    self.pickButton.layer.cornerRadius = 5;
    
#warning magic code
    //pickerView label
    UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pickerView.frame.size.width/3.0 -109, self.pickerView.frame.size.height / 2 - 51, 100, 100)];
    quantityLabel.font = [UIFont boldSystemFontOfSize:17];
    quantityLabel.textColor = [UIColor colorWithRed:1
                                              green:1
                                               blue:1
                                              alpha:85.0/100];
    quantityLabel.text = @"quantity";
    [self.pickerView addSubview:quantityLabel];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pickerView.frame.size.width/3.0*2 +40, self.pickerView.frame.size.height / 2 - 51, 100, 100)];
    numberLabel.font = [UIFont boldSystemFontOfSize:17];
    numberLabel.textColor = [UIColor colorWithRed:1
                                            green:1
                                             blue:1
                                            alpha:85.0/100];
    numberLabel.text = @"lucky";
    [self.pickerView addSubview:numberLabel];
}

- (void)setup
{
    //generate Dice
    self.uiviewArray = [[NSMutableArray alloc] init];
    self.buttonArray = [[NSMutableArray alloc] init];
    
    NSInteger maxColumn = 3;
    NSInteger quantity = 9;
    
    CGFloat width = (self.diceView.frame.size.width -(maxColumn-1)*10)/ maxColumn;
    
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
        tmpView.backgroundColor = [self colorWithHexString:@"#3B577D"];
        tmpView.layer.masksToBounds = NO;
        
        UIButton *tmpButton = [[UIButton alloc] initWithFrame:tmpView.frame];
        //渲染图片时用
        tmpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        tmpButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        
        //tmpButton.titleLabel.adjustsFontSizeToFitWidth = true;
        [tmpButton addTarget:self action:@selector(dicePress:) forControlEvents:UIControlEventTouchUpInside];
        
        [tmpView addSubview:tmpButton];
        [self.diceView addSubview:tmpView];
        tmpView.hidden = true;
        
        [self.uiviewArray addObject:tmpView];
        [self.buttonArray addObject:tmpButton];
        
    }
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

- (IBAction)pick:(UIButton *)sender
{
    self.annotationLabel.text = @"";
#warning need restructure
    CAKeyframeAnimation *morphX = [[CAKeyframeAnimation alloc] init];
    morphX.keyPath = @"transform.scale.x";
    morphX.values = @[@1, @1.3, @0.7, @1.3, @1];
    morphX.keyTimes = @[@0, @0.2, @0.4, @0.6, @0.8, @1];
    
    morphX.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.165 :0.84 :0.44 :1];
    morphX.duration = 0.5;
    //morphX.repeatCount = repeatCount;
    CAKeyframeAnimation *morphY = [[CAKeyframeAnimation alloc] init];
    morphY.keyPath = @"transform.scale.y";
    morphY.values = @[@1, @0.7, @1.3, @0.7, @1];
    morphY.keyTimes = @[@0, @0.2, @0.4, @0.6, @0.8, @1];
    morphY.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.165 :0.84 :0.44 :1];
    morphY.duration = 0.5;
    
    
    if(self.quantity < self.random.quantity)
    {
        self.random.quantity = self.quantity;
        [self.pickerView selectRow:self.random.quantity-1 inComponent:1 animated:true];
    }
    
    [self.pickButton.layer addAnimation:morphX forKey:nil];
    [self.pickButton.layer addAnimation:morphY forKey:nil];
    
    [self resetViewStatusArrayToQuestion];
    if(self.quantity == self.lastQuantity)
    {
        if(!self.isPicking)
        {
            self.isPicking = true;
            __block NSInteger index = 0;
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                             repeats:true
                                                               block:^(NSTimer * _Nonnull timer) {
                                                                   if(index < self.quantity)
                                                                   {
                                                                       [self dicePress:self.buttonArray[index]];
                                                                       index++;
                                                                   }
                                                                   else
                                                                   {
                                                                       //避开动画时间，动画结束后才刷新
                                                                       [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                                                       repeats:false
                                                                                                         block:^(NSTimer * _Nonnull timer) {
                                                                                                             [self refreshViewStatusArrayByRandom];
                                                                                                             self.isPicking = false;
                                                                                                         }];
                                                                       [timer invalidate];
                                                                   }
                                                               }];
            [timer fire];
        }
    }
    else
    {
        self.lastQuantity = self.quantity;
        [self resetPickView];
        
        //避开动画时间，动画结束后才刷新
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                        repeats:false
                                          block:^(NSTimer * _Nonnull timer) {
                                                      [self refreshViewStatusArrayByRandom];
                                          }];
    }
}

- (void)refreshViewStatusArrayByRandom
{
    //防止PickerView还没结束滑动就Pick，导致越界问题
    if(self.quantity < self.random.quantity)
    {
        self.random.quantity = self.quantity;
        [self.pickerView selectRow:self.random.quantity-1 inComponent:1 animated:true];
    }
    
    NSMutableArray *resultArray = [self.random generateList];
    
    for(int i=0;i<self.quantity;i++)
    {
        self.buttonStatusArray[i] = [NSNumber numberWithInteger:ViewStatusWrong];
    }
    for(NSString *result in resultArray)
    {
        NSInteger index = [result integerValue];
        //1到quantity的随机数（包括quantity）
        self.buttonStatusArray[index-1] = [NSNumber numberWithInteger:ViewStatusCorrect];
    }
}

- (void)resetViewStatusArrayToQuestion
{
    for(int i=0;i<self.quantity;i++)
    {
        self.buttonStatusArray[i] = [NSNumber numberWithInteger:ViewStatusQuestion];
    }
}

- (void)dicePress:(UIButton*)sender
{
    NSInteger index = [self.buttonArray indexOfObject:sender];
    NSNumber *number = self.buttonStatusArray[index];
    ViewStatus status = [number integerValue];
    if(status == ViewStatusFliped)
        return;
    
    NSLog(@"Dice");
    UIView *tmpUiView = sender.superview;
    [UIView animateWithDuration:0.1
                     animations:^{
                         tmpUiView.backgroundColor = [self colorWithHexString:@"#6983ac"];
                     }completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              tmpUiView.backgroundColor = [self colorWithHexString:@"#3B577D"];
                                              
                                          }];
                     }];
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / self.diceView.layer.frame.size.width/2;
    
    //[sender setTitle:@"" forState:UIControlStateNormal];
    [sender setImage:nil forState:UIControlStateNormal];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(perspective, CATransform3DMakeRotation(M_PI, 0, 1, 0))];
    animation.duration = 0.5;
    //animation.beginTime = CACurrentMediaTime();
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.175 :0.885 :0.32 :1.275];
    [tmpUiView.layer addAnimation:animation forKey:nil];
    
    NSTimer *currentTimer;
    if(self.currentTimerArray.count > index)
    {
        currentTimer = self.currentTimerArray[index];
        [currentTimer invalidate];//防止多次调用
    }
    currentTimer =[NSTimer scheduledTimerWithTimeInterval:0.35
                                                  repeats:false
                                                    block:^(NSTimer * timer)
                   {
                       NSLog(@"Run");
                       [UIView transitionWithView:sender
                                         duration:0.2f
                                          options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseIn
                                       animations:^{
                                           [self changeDiceImage:sender];
                                           
                                       } completion:nil];
                   }];
    self.currentTimerArray[index] = currentTimer;
    
}

#pragma mark - untag method

- (void)resetPickView
{
    
    NSInteger maxColumn;
    NSInteger quantity = self.quantity;
    maxColumn = quantity <= 4 ? 2 : 3;
    maxColumn = quantity == 1 ? 1 : maxColumn;
    
    CGFloat width = (self.diceView.frame.size.width -(maxColumn-1)*10)/ maxColumn;
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
            if(i+1==quantity && i != 0)//the last one
            {
                if(x==0)
                {
                    x = self.diceView.frame.size.width/2.0f - width/2.0f;
                }
            }
            NSLog(@"x: %f y: %f",x,y);
            
            tmpView.frame = CGRectMake(x, y, width, width);
            if(quantity==1)
                tmpView.layer.cornerRadius = 10;
            else
                tmpView.layer.cornerRadius = 5;
            //redraw uiview shadow
            [self addShadow:tmpView];
            tmpButton.frame = tmpView.bounds;
            
            if(tmpView.hidden == false)
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
                                                                 tmpView.hidden = false;
                                                                 [self changeDiceImage:tmpButton];
                                                                
                                                                 
                                                                 [tmpView.layer addAnimation:self.showAnimation forKey:nil];
                                                                 NSLog(@"Timer");
                                                             }];
            self.currentTimerArray[i] = currentTimer;
        }
        else
        {
            [tmpView.layer addAnimation:self.hideAnimation forKey:nil];
            tmpView.hidden = true;
        }
    }
    
}

- (void)changeDiceImage:(UIButton*)sender
{
    NSInteger index = [self.buttonArray indexOfObject:sender];
    NSNumber *number = self.buttonStatusArray[index];
    ViewStatus status = [number integerValue];
    
    //不全部填充，效果相当于margin
    sender.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    
    switch (status)
    {
        case ViewStatusQuestion:
            [sender setImage:[UIImage imageNamed:@"question"] forState:UIControlStateNormal];
            [sender setImage:nil forState:UIControlStateHighlighted];
            break;
        case ViewStatusWrong:
            [sender setImage:[UIImage imageNamed:@"wrong"] forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"wrong"] forState:UIControlStateHighlighted];
            break;
        case ViewStatusCorrect:
            //钩的图片比较小，所以弄大一点
            sender.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            
            [sender setImage:[UIImage imageNamed:@"correct"] forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"correct"] forState:UIControlStateHighlighted];
            [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy] impactOccurred];
            break;
        case ViewStatusFliped:
            NSLog(@"Error: excepted login about ViewStatusFliped");
            break;
    }
    //只能操作一次
    self.buttonStatusArray[index]= [NSNumber numberWithInteger:ViewStatusFliped];
}

#pragma mark - <UIPickerViewDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return self.quantityMutableArray.count;
    }
    else
    {
        return self.numberMutableArray.count;
    }
}

#pragma mark - <UIPickerViewDelegate>

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView * newView = [[UIView alloc] init];
    //newView.backgroundColor = [UIColor blueColor];
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    //lbl.backgroundColor = [UIColor redColor];
    lbl.textAlignment = NSTextAlignmentRight;
    lbl.font=[UIFont systemFontOfSize:24];
    lbl.textColor = [self colorWithHexString:@"#FFFFFF"];
    [newView addSubview:lbl];
    
    
    [newView addConstraint:[NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:newView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0]];
    [newView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lbl]|" options:0 metrics:nil views:@{@"lbl":lbl}]];
    
    if(component == 0)
    {
        [newView addConstraint:[NSLayoutConstraint constraintWithItem:lbl
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:newView
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1 constant:10]];
        lbl.text = self.quantityMutableArray[row];
    }
    else
    {
        [newView addConstraint:[NSLayoutConstraint constraintWithItem:lbl
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:newView
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1 constant:0]];
        lbl.text = self.numberMutableArray[row];
    }
    
    return newView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        self.quantity = row +1;
    }
    else
    {
        self.random.quantity = (int32_t)row + 1;
    }
    NSLog(@"%d", self.random.quantity);
}

#pragma mark - generic mark

- (UIColor*)colorWithHexString:(NSString*)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
