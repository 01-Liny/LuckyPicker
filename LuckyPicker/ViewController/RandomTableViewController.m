//
//  RandomTableViewController.m
//  LuckyPicker
//
//  Created by BangshengXie on 21/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomTableViewController.h"
#import <CoreData/CoreData.h>
#import "IdentifierAvailability.h"
#import "RandomListContent+CoreDataClass.h"
#import "RandomListItem+CoreDataClass.h"
#import "AddContentViewController.h"
#import "PickListViewController.h"

@interface RandomTableViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedContext;
@property (strong, nonatomic) NSMutableArray *contentArray;

@end

@implementation RandomTableViewController

- (NSManagedObjectContext*)managedContext
{
    if(!_managedContext)
    {
        //1、创建模型对象
        //获取模型路径
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"List" withExtension:@"momd"];
        //根据模型文件创建模型对象
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        //2、创建持久化助理
        //利用模型对象创建助理对象
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        //数据库的名称和路径
        NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *sqlPath = [docStr stringByAppendingPathComponent:@"RandomList.sqlite"];
        NSLog(@"path = %@", sqlPath);
        NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
        
        //设置数据库相关信息
        [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:nil];
        
        //3、创建上下文
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        //关联持久化助理
        [context setPersistentStoreCoordinator:store];
        _managedContext = context;
    }
    return _managedContext;
}

- (NSMutableArray*)contentArray
{
    if(!_contentArray)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RandomListContent"];
        request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:RandomListContentSortKey ascending:true]];
        
        NSError *error = nil;
        NSArray *allContent = [self.managedContext executeFetchRequest:request
                                                                 error:&error];
        if(error)
        {
            NSLog(@"%@",error);
        }
        _contentArray = [NSMutableArray arrayWithArray:allContent];
    }
    return _contentArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"RandomTableView %@", NSStringFromSelector(_cmd));
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //1.调整(iOS7以上)表格分隔线边距
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"RandomTableView %@", NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
    self.contentArray = nil;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:RandomTableViewControllerAddSegueIdentifier])
    {
        if([segue.destinationViewController isKindOfClass:[AddContentViewController class]])
        {
            AddContentViewController *viewController = (AddContentViewController*)segue.destinationViewController;
            viewController.managedContext = self.managedContext;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArray.count;
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:RandomTableViewControllerCellIdentifier
                                           forIndexPath:indexPath];
    
    RandomListContent *tmp = [self.contentArray objectAtIndex:indexPath.row];
    cell.textLabel.text = tmp.title;
    
    
    //2.调整(iOS8以上)tableView边距
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    //3.调整(iOS8以上)view边距
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
}


#warning unused method (instead of by editActionForRowAtIndexPath)
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.contentArray removeObject:[self.contentArray objectAtIndex:indexPath.row]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.contentArray = nil;
        //[tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        AddContentViewController *destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:AddContentViewControllerIdentifier];
        destinationViewController.randomListContent = self.contentArray[indexPath.row];
        destinationViewController.managedContext = self.managedContext;
        [self.navigationController presentViewController:destinationViewController
                                                animated:true
                                              completion:nil];
        
        // 在最后希望cell可以自动回到默认状态，所以需要退出编辑模式
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // 首先改变model
        
        [self.managedContext deleteObject:[self.contentArray objectAtIndex:indexPath.row]];
        [self.contentArray removeObjectAtIndex:indexPath.row];
        
        //保存
        [self.managedContext save:nil];
        // 接着刷新view
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        // 不需要主动退出编辑模式，上面更新view的操作完成后就会自动退出编辑模式
    }];
    
    return @[deleteAction, editAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PickListViewController *destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:PickListViewControllerIdentifier];
    
    destinationViewController.randomListContent = self.contentArray[indexPath.row];
    destinationViewController.managedContext = self.managedContext;
    
    [self.navigationController showViewController:destinationViewController
                                           sender:self];
}

@end
