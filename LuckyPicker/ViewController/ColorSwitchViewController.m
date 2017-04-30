//
//  ColorSwitchViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 30/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "ColorSwitchViewController.h"

@interface ColorSwitchViewController ()

@property (weak, nonatomic) IBOutlet UIView *uiview;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIView *passcodeView;

@end

@implementation ColorSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if(selectedSegment == 0)
    {
        [UIView transitionWithView:self.uiview
                          duration:0.65
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.passcodeView.hidden = true;
                            self.colorView.hidden = false;
                        }
                        completion:nil];
        NSLog(@"0");
    }
    else
    {
        [UIView transitionWithView:self.uiview
                          duration:0.65
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.colorView.hidden = true;
                            self.passcodeView.hidden = false;
                        } completion:nil];
        NSLog(@"1");
    }
}

@end
