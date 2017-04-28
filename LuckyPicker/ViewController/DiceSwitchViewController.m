//
//  DiceSwitchViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 28/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "DiceSwitchViewController.h"

@interface DiceSwitchViewController ()

@property (weak, nonatomic) IBOutlet UIView *uiview;
@property (weak, nonatomic) IBOutlet UIView *diceUiView;
@property (weak, nonatomic) IBOutlet UIView *castUiView;

@end

@implementation DiceSwitchViewController

- (void)viewDidLoad
{
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
                            self.diceUiView.hidden = true;
                            self.castUiView.hidden = false;
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
                            self.diceUiView.hidden = false;
                            self.castUiView.hidden = true;
                        } completion:nil];
        NSLog(@"1");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
