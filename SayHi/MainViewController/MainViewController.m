//
//  MainViewController.m
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property MenuBarViewController *menuBarVC;
@property ChatViewController *chatVC;
@property ContactsViewController *contactsVC;

@property NSViewController *currentVC;

@property SayHiManagerCenter *shManagerCenter;
@property dispatch_queue_t messageQueue;
@property NSMutableDictionary *findServiceDict;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.messageQueue = dispatch_queue_create("sayhi.messagequeue", DISPATCH_QUEUE_SERIAL);
    self.findServiceDict = [NSMutableDictionary dictionary];
    
    self.shManagerCenter = [[SayHiManagerCenter alloc] init];
    self.shManagerCenter.delegate = self;
    [self.shManagerCenter initManager];
    
    self.menuBarVC = [[MenuBarViewController alloc] init];
    self.menuBarVC.view.autoresizingMask = NSViewHeightSizable;
    [self.menuBarVC.view setFrame:NSMakeRect(0, 0, 70, 480)];
    self.menuBarVC.delegate = self;
    
    self.chatVC = [[ChatViewController alloc] init];
    self.chatVC.delegate = self;
    [self.chatVC.view setFrame:NSMakeRect(70, 0, 730, 480)];
    //self.chatVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.chatVC initChatView];
    
    self.contactsVC = [[ContactsViewController alloc] init];
    self.contactsVC.delegate = self;
    [self.contactsVC initView];
    [self.contactsVC.view setFrame:NSMakeRect(70, 0, 730, 480)];
    //self.menuBarVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    //[self.mainVC.view setFrameSize:self.window.contentView.frame.size];
    //[leftView setFrameSize:NSMakeSize(70, 480)];
    [self.view addSubview:self.menuBarVC.view];
    
    //[chatView setFrameSize:NSMakeSize(730, 480)];
    
    //[self showChatView];
    [self showContactView];
}
-(void)showChatView{
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    self.chatVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.chatVC.view setFrameSize:self.view.frame.size];
    [self.view addSubview:self.chatVC.view];
    [self addChildViewController:self.chatVC];
    self.currentVC = self.chatVC;
}
-(void)showContactView{
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    self.contactsVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.contactsVC.view setFrameSize:self.view.frame.size];
    [self.view addSubview:self.contactsVC.view];
    [self addChildViewController:self.contactsVC];
    self.currentVC = self.contactsVC;
}
-(void)showConfigView{
    
}
#pragma mark -- Delegate MenuBar Event
-(void)eventFromMenuBarView:(NSDictionary *)event{
    NSString *type = [event objectForKey:@"type"];
    NSLog(@"event from menu bar:%@",event);
    if ([type isEqualToString:@"click"]) {
        NSString *btn = [event objectForKey:@"button"];
        if ([btn isEqualToString:@"message"]) {
            [self showChatView];
        }else if([btn isEqualToString:@"contact"]){
            [self showContactView];
        }else if([btn isEqualToString:@"config"]){
            [self showConfigView];
        }
    }
}
#pragma mark -- Delegate ContactsView Event
-(void)eventFromContactsView:(NSDictionary *)event{
    NSString *type = [event objectForKey:@"type"];
    NSLog(@"event from contact view:%@",event);
    if ([type isEqualToString:@"doubleclick"]) {
        //NSString *status = [event objectForKey:@"status"];
        NSInteger index = [[event objectForKey:@"index"] integerValue];
        BonjourService *service = [self.contactsVC.serviceListArr objectAtIndex:index];
        [self.chatVC updateSelectService:service];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showChatView];
        });
        
    }
}
#pragma mark -- Delegate SayHiManagerCenter Event
-(void)eventFromSayHiManagerCenter:(NSDictionary *)event{
    NSString *type = [event objectForKey:@"type"];
    NSLog(@"event from SayHiManager center:%@",event);
    if ([type isEqualToString:@"findService"]) {
        BonjourService *service = [event objectForKey:@"service"];
        [self.contactsVC addServiceItem:service];
        NSString *uuid = [service.SERV_UUID UUIDString];
        [self.findServiceDict setObject:service forKey:uuid];
    }
    else if([type isEqualToString:@"removeService"]){
        BonjourService *service = [event objectForKey:@"service"];
        [self.contactsVC removeServiceItem:service];
        NSString *uuid = [service.SERV_UUID UUIDString];
        [self.findServiceDict removeObjectForKey:uuid];
        [self.chatVC removedChatService:service];
    }
    else if([type isEqualToString:@"message"]){
        //@{@"type":@"message",@"data":recvMsg,@"serviceUUID":serv_uuid}
        NSString *uuid = [event objectForKey:@"serviceUUID"];
        BonjourService *service = [self.findServiceDict objectForKey:uuid];
        [self.chatVC receivedMsg:event fromService:service];
    }
}
#pragma mark -- Delegate EventFromChatViewController
-(void)eventFromChatView:(NSDictionary *)event{
    //@{@"type":@"sendMsg",@"msg":txt,@"service":self.chatService}
    NSLog(@"[MainVC]event from chat view:%@",event);
    NSString *type = [event objectForKey:@"type"];
    if ([type isEqualToString:@"sendMsg"]) {
        BonjourService *service = [event objectForKey:@"service"];
        NSString *msgTXT = [event objectForKey:@"msg"];
        [self.shManagerCenter sendTo:service msg:msgTXT];
    }
    else if([type isEqualToString:@"uploadFile"]){
        BonjourService *service = [event objectForKey:@"service"];
        NSString *filePath = [event objectForKey:@"file"];
        [NSThread detachNewThreadWithBlock:^{
            [self.shManagerCenter sendTo:service file:filePath];
        }];
    }
}
@end
