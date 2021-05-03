//
//  MessageViewController.m
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "MessageViewController.h"
#import "MsgListItemFrom.h"
#import "MsgListItemMe.h"

@interface MessageViewController ()

@property NSMutableArray *msgListArray;
@property BonjourService *chatService;
@property UploadFileViewController *uploadFileVC;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [nameLabelField setStringValue:@"No Select"];
}
-(void)viewWillAppear{
    if (self.chatService == nil) {
        [inputTextField setEnabled:NO];
        [uploadFileBtn setEnabled:NO];
    }else{
        [inputTextField setEnabled:YES];
        [uploadFileBtn setEnabled:YES];
    }
}
-(void)disabledCurrentMsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.msgListArray = [NSMutableArray array];
        [self->nameLabelField setStringValue:@"No Select"];
        [self->inputTextField setEnabled:NO];
        [self->uploadFileBtn setEnabled:NO];
        [self updateMsgTableView];
    });
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self->msgListTableView registerNib:[[NSNib alloc] initWithNibNamed:@"MsgListItemViewFrom" bundle:nil] forIdentifier:@"msglistitemfrom"];
    [self->msgListTableView registerNib:[[NSNib alloc] initWithNibNamed:@"MsgListItemViewMe" bundle:nil] forIdentifier:@"msglistitemme"];
}

-(void)initMsgView{
    self.msgListArray = [[NSMutableArray alloc] init];
    self.uploadFileVC = [[UploadFileViewController alloc] init];
    self.uploadFileVC.delegate = self;
    
    
    [msgListTableView reloadData];
}
-(void)receivedMsg:(NSDictionary *)msg{
    NSLog(@"[MessageVC]received msg:%@",msg);
    [self.msgListArray addObject:msg];
    [self updateMsgTableView];
    
}
-(void)updateService:(BonjourService *)serv msgListArr:(NSArray * _Nullable )msgArr{
    if (msgArr != nil) {
        self.msgListArray = [[NSMutableArray alloc] initWithArray:msgArr];
    }else{
        self.msgListArray = [NSMutableArray array];
    }
    self.chatService = serv;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->nameLabelField setStringValue:[NSString stringWithFormat:@"To:%@",serv.nickname]];
        [self->inputTextField setEnabled:YES];
        [self->uploadFileBtn setEnabled:YES];
    });
    [self updateMsgTableView];
}
-(void)updateMsgTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger rowRefresh = [self.msgListArray count] - 1;
        //NSIndexSet *reloadIndexSet = [[NSIndexSet alloc] initWithIndex:rowRefresh];
        //NSIndexSet *columnIndexSet = [[NSIndexSet alloc] initWithIndex:0];
        //[self->msgListTableView reloadDataForRowIndexes:reloadIndexSet columnIndexes:columnIndexSet];
        [self->msgListTableView reloadData];
        [self->msgListTableView scrollRowToVisible:rowRefresh];
        [self->msgListTableView display];
    });
}
-(IBAction)uploadFileBtnAction:(id)sender{
    self.uploadFileVC.serviceNickName = self.chatService.nickname;
    [self presentViewControllerAsSheet:self.uploadFileVC];
}
-(IBAction)inputTextFieldAction:(id)sender{
    NSString *txt = [inputTextField stringValue];
    if ([txt length] == 0) {
        return;
    }
    NSLog(@"[TX]%@",txt);
    [inputTextField setStringValue:@""];
    NSDictionary *event = @{@"type":@"sendMsg",@"msg":txt,@"service":self.chatService};
    [self.delegate eventFromMessageView:event];
}
#pragma mark -- Delegate DragDropIputField
/***
 第五步：实现dragdropview的代理函数，如果有数据返回就会触发这个函数
 ***/
-(void)dragDropViewFileList:(NSArray *)fileList{
    //如果数组不存在或为空直接返回不做处理（这种方法应该被广泛的使用，在进行数据处理前应该现判断是否为空。）
    if(!fileList || [fileList count] <= 0)return;
    //在这里我们将遍历这个数字，输出所有的链接，在后台你将会看到所有接受到的文件地址
    for (int n = 0 ; n < [fileList count] ; n++) {
        NSLog(@">>> %@",[fileList objectAtIndex:n]);
    }
    
}

#pragma mark -- Delegate UploadFileViewController
-(void)eventFromUploadFileView:(NSDictionary *)event{
    NSLog(@"[MsgVC]event from upload file view:%@",event);
    NSDictionary *dict = @{@"type":@"uploadFile",@"file":[event objectForKey:@"file"],@"service":self.chatService};
    [self.delegate eventFromMessageView:dict];
}
#pragma mark table datasource
//设置行数 通用
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    //NSLog(@"conttents.count...");
    //return contents.count;
    NSString *identifier = [tableView identifier];
    if([identifier isEqualToString:@"msglistTV"]){
        return [self.msgListArray count];
    }else{
        return 0;
    }
}

//-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
       // return [contents objectAtIndex:row];
//}

#pragma mark table delegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NSString *identifier = [tableView identifier];
    //NSLog(@"identifier:%@",identifier);
    if([identifier isEqualToString:@"msglistTV"]){
        NSDictionary *msg = [self.msgListArray objectAtIndex:row];
        NSString *msgStr = [msg objectForKey:@"content"];
        CGFloat add_h = 0.0;
        if ([msgStr length] > 42) {
            add_h = [msgStr length] / 42 * 18;
        }
        return 55 + add_h;
    }
    else{
        return 50;
    }
    
}

//View-base
//设置某个元素的具体视图
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableView identifier];
    //NSLog(@"identifier:%@",identifier);
    if([identifier isEqualToString:@"msglistTV"]){
        NSDictionary *msg = [self.msgListArray objectAtIndex:row];
        NSString *from = [msg objectForKey:@"from"];
        if ([from isEqualToString:@"Me"]) {
            MsgListItemMe *msgItem =[tableView makeViewWithIdentifier:@"msglistitemme" owner:self];
            [msgItem.titleLabelField setStringValue:[msg objectForKey:@"timestamp"]];
            [msgItem.contentField setStringValue:[msg objectForKey:@"content"]];
            //self.msgFieldCurrentWidth = msgItem.contentField.frame.size.width;
            [msgItem.contentField setEditable:YES];
            return msgItem;
        }else{
            MsgListItemFrom *msgItem =[tableView makeViewWithIdentifier:@"msglistitemfrom" owner:self];
            [msgItem.titleLabelField setStringValue:[msg objectForKey:@"timestamp"]];
            [msgItem.contentField setStringValue:[msg objectForKey:@"content"]];
            return msgItem;
        }
        
    }
    else{
        return nil;
    }
    
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    //NSTableView *tableView = notification.object;
    //NSString *identifier = [tableView identifier];
    //NSLog(@"identifier:%@",identifier);
    
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    
    return NO;
}

@end
