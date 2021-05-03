//
//  ChatViewController.m
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "ChatViewController.h"


@interface ChatViewController ()

@property ChatListItem *chatListItem;
@property MessageViewController *messageVC;

//@property NSMutableArray *msgDictArr;
@property NSMutableDictionary *recvMsgDict;
@property NSMutableDictionary *msgReadStatusDict;
@property NSUInteger selectChatIndex;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.messageVC = [[MessageViewController alloc] init];
    self.messageVC.delegate = self;
    [self.messageVC initMsgView];
    [self.messageVC.view setFrameSize:NSMakeSize(469, 480)];
    [self.messageVC.view setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    [messageView addSubview:self.messageVC.view];
    
}

-(void)awakeFromNib{
    [self->chatListTableView registerNib:[[NSNib alloc] initWithNibNamed:@"ChatListItemView" bundle:nil] forIdentifier:@"chatlistitem"];
    
}
-(void)initChatView{
    self.chatListItem = [[ChatListItem alloc] init];
    self.chatServiceArr = [NSMutableArray array];
    self.recvMsgDict = [NSMutableDictionary dictionary];
    self.msgReadStatusDict = [NSMutableDictionary dictionary];
    //self.chatListArray = [NSMutableArray array];

    [chatListTableView reloadData];
    self.selectChatIndex = -1;

}

-(IBAction)addBtnAction:(id)sender{
    
}

-(void)viewWillAppear{
    [self updateChatTableView];
    
}
-(void)updateChatTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->chatListTableView reloadData];
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:self.selectChatIndex];
        [self->chatListTableView.animator selectRowIndexes:indexSet byExtendingSelection:NO];
        [self->chatListTableView scrollRowToVisible:self.selectChatIndex];
    });
}
-(void)removedChatService:(BonjourService *)service{
    BOOL isExist = NO;
    NSUInteger index = 0;
    for (BonjourService *serv in self.chatServiceArr) {
        if ([serv.SERV_UUID isEqual:service.SERV_UUID]) {
            isExist = YES;
            //[self.chatServiceArr removeObject:serv];
            //self.selectChatIndex = index;
            break;
        }
        index +=1;
    }
    if (isExist == YES) {
        [self.chatServiceArr removeObjectAtIndex:index];
        if (self.selectChatIndex == index) {
            self.selectChatIndex = -1;
            [self.messageVC disabledCurrentMsg];
        }
        if ([self.recvMsgDict objectForKey:[service.SERV_UUID UUIDString]] != nil) {
            [self.recvMsgDict removeObjectForKey:[service.SERV_UUID UUIDString]];
        }
    }
    [self updateChatTableView];
}
-(void)updateSelectService:(BonjourService *)service{
    //self.currentChatService = service;
    BOOL isExist = NO;
    NSUInteger index = 0;
    for (BonjourService *serv in self.chatServiceArr) {
        if ([serv isEqual:service]) {
            isExist = YES;
            self.selectChatIndex = index;
            break;
        }
        index +=1;
    }
    if (isExist == NO) {
        [self.chatServiceArr addObject:service];
        //[self.chatListArray addObject:service];
        self.selectChatIndex = self.chatServiceArr.count - 1;
    }
    NSArray *msgArr = [self.recvMsgDict objectForKey:[service.SERV_UUID UUIDString]];
    NSLog(@"[ChatVC]msg arr:%@",msgArr);
    [self.messageVC updateService:service msgListArr:msgArr];
}
-(void)receivedMsg:(NSDictionary *)msg fromService:(BonjourService *)serv{
    NSString *msgTXT = [msg objectForKey:@"data"];
    NSString *serv_uuid = [msg objectForKey:@"serviceUUID"];
    NSLog(@"[ChatVC]received msg:%@ uuid:%@",msgTXT,serv_uuid);
    NSDictionary *msgDict = @{@"from":serv_uuid,@"timestamp":[self getCurrentTime],@"content":msgTXT};
    [self insertMsg:msgDict withServUUID:serv_uuid];
    if ([self.chatServiceArr count] == 0) { //chat list是空的
        //[self updateSelectService:serv];
        [self.chatServiceArr addObject:serv];
        [self.messageVC updateService:serv msgListArr:nil];
        [self.msgReadStatusDict setObject:@(NO) forKey:serv_uuid];
    }
    else{ //chat list不为空
        BOOL isExist = NO;
        NSUInteger index = 0;
        //检查service chat是否存在list中
        for (BonjourService *service in self.chatServiceArr) {
            if ([[service.SERV_UUID UUIDString] isEqualToString:serv_uuid]) {
                isExist = YES;
                break;
            }
            index += 1;
        }
        if (isExist == YES) {
            if (self.selectChatIndex == index) { //存在且选中
                [self.messageVC receivedMsg:msgDict];
                [self.msgReadStatusDict setObject:@(YES) forKey:serv_uuid];
            }else{ //存在未选中
                [self.msgReadStatusDict setObject:@(NO) forKey:serv_uuid];
            }
            //NSTableColumn *col = [chatListTableView tableColumnWithIdentifier:@"chatlisttablecol"];
            dispatch_async(dispatch_get_main_queue(), ^{
                ChatListItem *item = [self->chatListTableView viewAtColumn:0 row:self.selectChatIndex makeIfNecessary:YES];
                [item.lastMsgLabelField setStringValue:msgTXT];
                NSIndexSet *rowIndexSet = [[NSIndexSet alloc] initWithIndex:self.selectChatIndex];
                NSIndexSet *colIndexSet = [[NSIndexSet alloc] initWithIndex:0];
                [self->chatListTableView reloadDataForRowIndexes:rowIndexSet columnIndexes:colIndexSet];
            });
            
        }else{ //list中不存在
            [self.chatServiceArr addObject:serv];
            //self.selectChatIndex = [self.chatServiceArr count] - 1;
            [self.msgReadStatusDict setObject:@(NO) forKey:serv_uuid];
            
        }
        
    }
    [self updateChatTableView];
}

-(void)insertMsg:(NSDictionary *)msg withServUUID:(NSString *)uuid{
    NSMutableArray *msgArr = [self.recvMsgDict objectForKey:uuid];
    if (msgArr == nil) {
        msgArr = [NSMutableArray array];
        [msgArr addObject:msg];
        [self.recvMsgDict setObject:msgArr forKey:uuid];
    }else{
        [msgArr addObject:msg];
    }
    NSLog(@"[ChatVC]after insert msg:%@",self.recvMsgDict);
}
-(NSString *)getCurrentTime{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    return [dateFormat stringFromDate:[NSDate date]];
}

#pragma mark -- Delegate EventFromMessageView
-(void)eventFromMessageView:(NSDictionary *)event{
    //@{@"type":@"sendMsg",@"msg":txt,@"service":self.chatService};
    NSString *type = [event objectForKey:@"type"];
    if ([type isEqualToString:@"sendMsg"]) {
         //@{@"from":serv_uuid,@"timestamp":[self getCurrentTime],@"content":msgTXT};
        BonjourService *service = [event objectForKey:@"service"];
        NSString *msgTXT = [event objectForKey:@"msg"];
        NSDictionary *recvMsg = @{@"from":@"Me",@"timestamp":[self getCurrentTime],@"content":msgTXT};
        [self insertMsg:recvMsg withServUUID:[service.SERV_UUID UUIDString]];
        [self.messageVC receivedMsg:recvMsg];
    }
    else if([type isEqualToString:@"uploadFile"]){
        BonjourService *service = [event objectForKey:@"service"];
        NSString *msgTXT = [NSString stringWithFormat:@"send file:%@",[event objectForKey:@"file"]];
        NSDictionary *recvMsg = @{@"from":@"Me",@"timestamp":[self getCurrentTime],@"content":msgTXT};
        [self insertMsg:recvMsg withServUUID:[service.SERV_UUID UUIDString]];
        [self.messageVC receivedMsg:recvMsg];
    }
    [self.delegate eventFromChatView:event];
}

#pragma mark table datasource
//设置行数 通用
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    //NSLog(@"conttents.count...");
    //return contents.count;
    NSString *identifier = [tableView identifier];
    if ([identifier isEqualToString:@"chatlistTV"]) {
        return [self.chatServiceArr count];
    }
    else{
        return 0;
    }
}

//-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
       // return [contents objectAtIndex:row];
//}

#pragma mark table delegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NSString *identifier = [tableView identifier];
    NSLog(@"identifier:%@",identifier);
    if ([identifier isEqualToString:@"chatlistTV"]) {
        return 65.0;
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
    NSLog(@"identifier:%@",identifier);
    if ([identifier isEqualToString:@"chatlistTV"]) {
        BonjourService *service = [self.chatServiceArr objectAtIndex:row];
        BOOL msgReadStatus = [[self.msgReadStatusDict objectForKey:[service.SERV_UUID UUIDString]] boolValue];
        ChatListItem *item = [tableView makeViewWithIdentifier:@"chatlistitem" owner:self];
        [item.nameLabelField setStringValue:service.nickname];
        [item.lastMsgLabelField setStringValue:@""];
        if (msgReadStatus == YES) {
            [item.unReadFlagIV setHidden:YES];
        }else{
            [item.unReadFlagIV setHidden:NO];
        }
        NSMutableArray *msgArr = [self.recvMsgDict objectForKey:[service.SERV_UUID UUIDString]];
        if (msgArr != nil && [msgArr count] > 0) {
            for (NSDictionary *msg in msgArr) {
                if (![[msg objectForKey:@"from"] isEqualToString:@"Me"]) {
                    [item.lastMsgLabelField setStringValue:[msg objectForKey:@"content"]];
                }
            }
        }
        //[item]
        NSLog(@"item:%@",item);
        return item;
    }
    else{
        return nil;
    }
    
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = notification.object;
    NSString *identifier = [tableView identifier];
    //NSLog(@"identifier:%@",identifier);
    if ([identifier isEqualToString:@"chatlistTV"]){
        NSInteger row = [chatListTableView selectedRow];
        NSLog(@"click chat list tableview row:%ld",(long)row);
        if (row > -1) {
            self.selectChatIndex = row;
            BonjourService *service = [self.chatServiceArr objectAtIndex:row];
            NSArray *msgArr = [self.recvMsgDict objectForKey:[service.SERV_UUID UUIDString]];
            NSLog(@"[ChatVC]msg arr:%@",msgArr);
            [self.messageVC updateService:service msgListArr:msgArr];
            [self.msgReadStatusDict setObject:@(YES) forKey:[service.SERV_UUID UUIDString]];
            ChatListItem *item = [chatListTableView viewAtColumn:0 row:self.selectChatIndex makeIfNecessary:YES];
            [item.unReadFlagIV setHidden:YES];
        }
    }
    
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSString *identifier = [tableView identifier];
    //NSLog(@"identifier:%@",identifier);
    if ([identifier isEqualToString:@"chatlistTV"]){
        return true ;
    }else{
        return false;
    }
    
}
@end
