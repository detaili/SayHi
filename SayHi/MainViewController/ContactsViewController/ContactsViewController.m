//
//  ContactsViewController.m
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactItemView.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self->serviceListTableView registerNib:[[NSNib alloc] initWithNibNamed:@"ContactItemView" bundle:nil] forIdentifier:@"contactitem"];

    [serviceListTableView setTarget:self];
    [serviceListTableView setDoubleAction:NSSelectorFromString(@"doubleClick:")]; //setDoubleAction双击选择事件
}

- (void) doubleClick: (id)sender
{
    NSInteger rowNumber = [serviceListTableView clickedRow];
    NSLog(@"Double Clicked.%ld ",rowNumber);
    if (rowNumber > -1) {
        NSDictionary *event = @{@"type":@"doubleclick",@"index":@(rowNumber)};
        [self.delegate eventFromContactsView:event];
    }
    
    // ...
}
-(void)initView{
    self.serviceListArr = [NSMutableArray array];
    
}
-(void)addServiceItem:(BonjourService *)service{
    [self.serviceListArr addObject:service];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->serviceListTableView reloadData];
    });
    
}
-(void)removeServiceItem:(BonjourService *)service{
    [self.serviceListArr removeObject:service];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->serviceListTableView reloadData];
    });
}

#pragma mark table datasource
//设置行数 通用
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.serviceListArr count];
    
}
#pragma mark table delegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    //NSString *identifier = [tableView identifier];
    //NSLog(@"identifier:%@",identifier);
    return 60;
    
}

//View-base
//设置某个元素的具体视图
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableView identifier];
    NSLog(@"identifier:%@",identifier);
    BonjourService *service = [self.serviceListArr objectAtIndex:row];
    ContactItemView *item = [tableView makeViewWithIdentifier:@"contactitem" owner:self];
    [item.nameLabelField setStringValue:service.nickname];
    NSString *address = [NSString stringWithFormat:@"IP:[%@] Port:[%@]",service.ipV4,service.port];
    [item.addressLabelField setStringValue:address];

    return item;

}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [serviceListTableView selectedRow];
    NSLog(@"click tableview row:%ld",(long)row);
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return true ;
}

@end
