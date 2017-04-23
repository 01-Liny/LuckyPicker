//
//  AddContentViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 22/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "AddContentViewController.h"

@interface AddContentViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *uiview;
@property (weak, nonatomic) IBOutlet UITextField *randomListTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) NSMutableArray *contentArray;
@property (strong, nonatomic) UITextField *currentTextField;
@property (assign, nonatomic) CGFloat currentOffset;

@end

@implementation AddContentViewController

- (NSMutableArray*)contentArray
{
    if(!_contentArray)
    {
        _contentArray = [NSMutableArray arrayWithArray:self.randomListContent.items.allObjects];
    }
    return _contentArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    self.randomListTitle.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTapped:)];
    [self.tableView addGestureRecognizer:tap];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    [self updateUI];
    
    if(self.randomListContent == nil)
    {
        RandomListContent *content = [NSEntityDescription insertNewObjectForEntityForName:@"RandomListContent"
                                                                   inManagedObjectContext:self.managedContext];
        content.title = @"";
        self.randomListContent = content;
    }
}

- (void)updateUI
{
    self.randomListTitle.text = self.randomListContent.title;
    if([self.randomListTitle.text isEqualToString:@""])
    {
        self.doneButton.enabled = false;
    }
    else
    {
        self.doneButton.enabled = true;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self clearEmptyItem];
    [self.presentingViewController dismissViewControllerAnimated:true
                                                      completion:nil];
    
}

#warning text 未结束编辑的时候 按done不会保存
- (IBAction)done:(id)sender
{
    [self clearEmptyItem];
    if(self.randomListTitle.text && ![self.randomListTitle.text isEqualToString:@""])
    {
        NSError *error;
        [self.managedContext save:&error];
        if(error)
        {
            NSLog(@"%@", error);
        }
    }
    [self.presentingViewController dismissViewControllerAnimated:true
                                                      completion:nil];
}

- (void)clearEmptyItem
{
        for(RandomListItem *tmp in self.contentArray)
        {
            NSLog(@"%@", tmp.name);
            if(!tmp.name || [tmp.name isEqualToString:@""])
                [self.managedContext deleteObject:tmp];
        }
        //reload contentArray use lazy instantiation
        self.contentArray = nil;
        [self.tableView reloadData];
}

#pragma mark - tap event

- (void)tableTapped:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:location];
    
    if(path)
    {
        // tap was on existing row, so pass it to the delegate method
        [self tableView:self.tableView didSelectRowAtIndexPath:path];
    }
    else
    {
        // handle tap on empty space below existing rows however you want
        [self.view endEditing:YES];
        NSLog(@"touch");
    }
}

#pragma mark - keyboard notification event

// 键盘弹出时
-(void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGFloat offset;
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD，如果需要的话)
    if([self.currentTextField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        offset = (self.currentTextField.superview.frame.size.height +  //为了多空出Add Item这一行（列表高度都是一样的
                          self.currentTextField.frame.size.height +
                          self.currentTextField.frame.origin.y+
                          self.currentTextField.superview.frame.origin.y +
                          self.currentTextField.superview.superview.frame.origin.y +
                          self.currentTextField.superview.superview.superview.frame.origin.y +
                          self.currentTextField.superview.superview.superview.superview.frame.origin.y
                          +0) - (self.uiview.frame.size.height - kbHeight);
    }
    else
    {
        offset = (self.currentTextField.frame.size.height +
                  self.currentTextField.frame.origin.y +
                  +0) - (self.uiview.frame.size.height - kbHeight);
    }
    self.currentOffset = offset;
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    //double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    if(offset > 0)
    {
        [self.tableView setContentOffset:CGPointMake(0, offset) animated:YES];
    }
    else
    {
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

//键盘消失时
-(void)keyboardWillHidden:(NSNotification*)notification
{
//    // 键盘动画时间
//    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    
//    //视图下沉恢复原状
//    [UIView animateWithDuration:duration animations:^{
//        self.uiview.frame = CGRectMake(0, 0, self.uiview.frame.size.width, self.uiview.frame.size.height);
//    }];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(!self.randomListTitle.text || [self.randomListTitle.text isEqualToString:@""])
    {
        self.doneButton.enabled = false;
    }
    else
    {
        self.doneButton.enabled = true;
    }
    
    if([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)textField.superview.superview];
        RandomListItem *item = self.contentArray[indexPath.row];
        item.name = textField.text;
    }
    else
    {
        self.randomListContent.title = self.randomListTitle.text;
    }
    self.currentTextField = nil;
    NSLog(@"Detected");
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contentArray.count + 1;
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row < self.contentArray.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Item"
                                               forIndexPath:indexPath];
        
        RandomListItem *item = [self.contentArray objectAtIndex:indexPath.row];
        
        UITextField *textField = cell.contentView.subviews[0];
        textField.delegate = self;
        textField.text = item.name;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Add"
                                               forIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= self.contentArray.count)
    {
        RandomListItem *tmp = [NSEntityDescription insertNewObjectForEntityForName:@"RandomListItem"
                                                            inManagedObjectContext:self.managedContext];
        tmp.title = self.randomListContent;
        
        [self.contentArray addObject:tmp];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];

        NSIndexPath *tmp1 = [NSIndexPath indexPathForRow:indexPath.row +1  inSection:0];
        [self.tableView deselectRowAtIndexPath:tmp1 animated:YES];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = cell.contentView.subviews[0];


        NSLog(@"%f", self.currentOffset);
        
        //[tableView layoutIfNeeded]; // Force layout so things are updated before resetting the contentOffset.
        //[tableView setContentOffset:offset];
        
        if(self.currentOffset > 0)
        {
            [tableView reloadData];
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:true
                                  scrollPosition:UITableViewScrollPositionTop];
            [tableView layoutIfNeeded];
        }
        [textField becomeFirstResponder];
    }
    else
    {
        [self.view endEditing:YES];
        NSLog(@"touch");
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.contentArray.count)
    {
        return true;
    }
    return false;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    NSLog(@"touch");
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        RandomListItem *tmp = self.contentArray[indexPath.row];
        [self.contentArray removeObject:tmp];
        [self.managedContext deleteObject:tmp];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationBottom];
        
        //[self.managedContext save:nil];
        
    }];
    return @[deleteAction];
}

#pragma mark - touch event

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    NSLog(@"touch");
}

@end
