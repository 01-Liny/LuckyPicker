//
//  PickListViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 23/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "PickListViewController.h"
#import "AddContentViewController.h"
#import "IdentifierAvailability.h"
#import "RandomList.h"

@interface PickListViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIView *pickView;
@property (weak, nonatomic) IBOutlet UIButton *pickButton;
@property (weak, nonatomic) IBOutlet UILabel *listLabel;

@property (strong, nonatomic) NSTimer *currentTimer;

@property (strong, nonatomic) RandomListContent *randomListContent;
@property (strong, nonatomic) NSMutableArray *numberMutableArray;
@property (strong, nonatomic) RandomList *randomList;
@property (assign, nonatomic) NSInteger maxQuantity;

@property (assign, nonatomic) Boolean isFirstRunViewDidLayoutSubviews;

@end

@implementation PickListViewController

#pragma mark - lazy instantiation

- (RandomListContent*)randomListContent
{
    if(!_randomListContent)
    {
        _randomListContent = [self.managedContext objectWithID:self.randomListContentID];
    }
    return _randomListContent;
}

- (RandomList *)randomList
{
    if(!_randomList)
    {
        _randomList = [[RandomList alloc] init];
        _randomList.toValue = (int32_t)self.maxQuantity - 1;//from 0 to maxQuantity-1
        _randomList.quantity = 1;
    }
    return _randomList;
}

- (NSInteger)maxQuantity
{
    return self.randomListContent.items.count;
}

- (NSMutableArray*)numberMutableArray
{
    if(!_numberMutableArray)
    {
        _numberMutableArray = [[NSMutableArray alloc] init];
        for(int i = 1; i <= self.maxQuantity; i++)
        {
            [_numberMutableArray addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _numberMutableArray;
}

#pragma mark - view did load

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    self.isFirstRunViewDidLayoutSubviews = true;
    
    [self setupPickView];
    NSLog(@"DidLoad");
}

- (void)setupPickView
{
    //pickButton
    self.pickButton.frame = self.pickView.frame;
    
    //numberLabel
    self.listLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(self.isFirstRunViewDidLayoutSubviews)
    {
        self.isFirstRunViewDidLayoutSubviews = false;
        
        //pickView
        self.pickView.layer.cornerRadius = 10;
        self.pickView.layer.masksToBounds = NO;
        [self addShadow:self.pickView];
        
        //add quantity label
        UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pickerView.frame.size.width/2+ 20, self.pickerView.frame.size.height / 2 - 51, 100, 100)];
        quantityLabel.font = [UIFont boldSystemFontOfSize:17];
        quantityLabel.textColor = [UIColor colorWithRed:1
                                                  green:1
                                                   blue:1
                                                  alpha:85.0/100];
        quantityLabel.text = NSLocalizedString(@"quantity", nil);
        [self.pickerView addSubview:quantityLabel];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Appear");
    [super viewWillAppear:true];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.pickView.backgroundColor = [self colorWithHexString:@"#3B577D"];
    
    [self.managedContext reset];//reset managedContext to discard unsaved changes
    self.randomListContent = nil;
    
    [self updateUI];
}

- (void)updateUI
{
    //reload use lazy instantiation
    //self.randomListContent = nil;
    self.title = self.randomListContent.title;
    
    self.numberMutableArray = nil;
    self.randomList = nil;
    
    
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:0
                   inComponent:0
                      animated:true];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button event

- (IBAction)pick:(id)sender
{
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
    
    //[self.listLabel setFont:[UIFont systemFontOfSize:100]];
    self.listLabel.text = @"";
    self.listLabel.numberOfLines = 1;
    
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
                                                              [UIView transitionWithView:self.listLabel
                                                                                duration:0.2f
                                                                                 options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseIn
                                                                              animations:^{
                                                                                  [self generate];
                                                                              } completion:nil];
                                                              
                                                          }];

}

- (IBAction)return:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}
- (IBAction)edit:(id)sender
{
    AddContentViewController *destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:AddContentViewControllerIdentifier];
    destinationViewController.randomListContent = self.randomListContent;
    destinationViewController.managedContext = self.managedContext;
    [self.navigationController presentViewController:destinationViewController
                                            animated:true
                                          completion:nil];
}

#pragma mark - generate

- (void)generate
{
    if(self.randomList.toValue < 0 )
        return;
    NSMutableArray *tmpList = [self.randomList generateList];
    NSMutableString *string = [NSMutableString new];
    NSArray *itemArray = [self.randomListContent.items allObjects];
    
    //bad code
    NSArray *tmpSizeArray = @[@"49",@"40",@"35",@"30",@"27",@"24",@"22",@"20",@"18",@"17",@"16"];
    
    CGFloat actualFontSize = 50;
    for (int index = 0; index < tmpList.count; index++)
    {
        NSInteger itemIndex = [tmpList[index] intValue];
        
        RandomListItem *item = itemArray[itemIndex];
        NSLog(@"item: %@", item.name);
        [string appendString:[NSString stringWithFormat:@"%@\n", item.name]];
        NSLog(@"string: %@", string);
        
        CGFloat tmpFontSize;
        CGFloat maxFontSize = 50;
        
        
        //人工干预字体大小，略蛋疼
        if(tmpList.count>=5)
        {
            maxFontSize = [[tmpSizeArray objectAtIndex:tmpList.count-5] integerValue];
        }
        
        NSString *ourText = item.name;
        
        [ourText sizeWithFont:[UIFont systemFontOfSize:maxFontSize] minFontSize:6 actualFontSize:&tmpFontSize forWidth:256 lineBreakMode:NSLineBreakByWordWrapping];
        NSLog(@"tmpFont %f",tmpFontSize);
        
        actualFontSize = actualFontSize < tmpFontSize ? actualFontSize : tmpFontSize;
    }
    self.listLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.listLabel.numberOfLines = tmpList.count;
    self.listLabel.text = string;
    [self.listLabel setFont:[UIFont systemFontOfSize:actualFontSize]];
}

#pragma mark - <UIPickerViewDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(self.numberMutableArray.count>15)
        return 15;
    else
        return self.numberMutableArray.count;
    
}

#pragma mark - <UIPickerViewDelegate>

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *columnView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30,100)];
    columnView.font = [UIFont systemFontOfSize:24];
    columnView.textColor = [self colorWithHexString:@"#FFFFFF"];
    columnView.text = self.numberMutableArray[row];
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
    self.randomList.quantity = row + 1;
}

#pragma mark - generic method

- (UIColor*)colorWithHexString:(NSString*)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
