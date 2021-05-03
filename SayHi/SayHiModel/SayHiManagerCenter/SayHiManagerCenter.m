//
//  SayHiManagerCenter.m
//  SayHi
//
//  Created by weidongcao on 2020/8/25.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "SayHiManagerCenter.h"

@implementation SayHiManagerCenter
{
    ServiceBrower *_brower;
    NSMutableArray *_serviceArray;
    HttpPostController *_httpPostController;
    dispatch_queue_t _findServiceQueue;
    
    NSString *postFileUrl;
    NSString *postMsgUrl;
    
    SayHiServer *sayHiServer;
    MessageCenterManager *msgCenterManager;
    NSUUID *serv_uuid;
}
-(void)initManager{
    // 启用通知
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    serv_uuid = [NSUUID UUID];
    NSLog(@"ME UUID:%@",[serv_uuid UUIDString]);
    _findServiceQueue = dispatch_queue_create("findservice.queue", DISPATCH_QUEUE_SERIAL);
    _httpPostController = [[HttpPostController alloc] init];
    //_httpPostFile.requestTimeout = 100.0;
    postFileUrl = @"";
    postFileUrl = @"";
    _serviceArray = [[NSMutableArray alloc] init];
    _brower = [[ServiceBrower alloc] init];
    _brower.delegate = self;
    [_brower initBrower];
    [self searchBonjourService];
    
    NSString *testmsg = @"{\"type\":\"msg\",\"message\":\"hello world\"}";
    NSDictionary *testdict = [JsonParser parseJSonStr:testmsg];
    NSLog(@"test dict:%@",testdict);
    NSLog(@"user name:%@",NSFullUserName());
    
    msgCenterManager = [[MessageCenterManager alloc] init];
    [msgCenterManager initManager];
    msgCenterManager.delegate = self;
    
    sayHiServer = [[SayHiServer alloc] init];
    if ([sayHiServer initServer:serv_uuid]) {
        NSLog(@"[Info] SayHi Server init OK!");
    }else{
        NSLog(@"[ERROR] SayHi Server init FAIL!");
    }
    
    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"download file path:%@",savePath);
}
-(void)searchBonjourService{
    //[serviceListBtn removeAllItems];
    [NSThread detachNewThreadWithBlock:^{
        [self->_brower startSearch:@"_SayHiService._tcp" domain:@"local."];
    }];
    
}
-(void)sendTo:(BonjourService *)service msg:(NSString *)txt{
    _httpPostController.SERV_UUID = serv_uuid;
    NSString *postUrl = [NSString stringWithFormat:@"http://%@:%@/message",service.ipV4,service.port];
    NSError *err = NULL;
    NSString *response = [_httpPostController sendMessageTo:postUrl message:txt timeout:5.0 error:&err];
    
}
-(void)sendTo:(BonjourService *)service file:(NSString *)path{
    _httpPostController.SERV_UUID = serv_uuid;
    NSString *postUrl = [NSString stringWithFormat:@"http://%@:%@/upload",service.ipV4,service.port];
    NSError *err = NULL;
    NSString *response = [_httpPostController uploadTo:postUrl withFile:path timeout:100.0 error:&err];
    NSNotification *notification = [NSNotification notificationWithName:@"sayhi.uploadfileresponse.notification" object:nil userInfo:@{@"response":response}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
#pragma mark - NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [center removeDeliveredNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#endif

-(void)pushNotification:(NSDictionary *)notif onlyHidden:(BOOL )onlyFlag{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (onlyFlag == YES && [[NSApplication sharedApplication] isActive]) {
            return;
        }
        #if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
        if (!NSClassFromString(@"NSUserNotificationCenter")) return;
        
        NSString *titleStr = [notif objectForKey:@"title"];
        NSString *info = [notif objectForKey:@"info"];

        NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = titleStr;
        userNote.informativeText = info;
        userNote.soundName = NSUserNotificationDefaultSoundName;
        [unc deliverNotification:userNote];
        #endif
    });
    
}

#pragma mark -- Delegate ServiceBrower
-(void)ServiceBrowerDidFindService:(BonjourService *)service{
    NSLog(@"service ip:%@",service.ipV4);
    
    dispatch_async(_findServiceQueue, ^{
        if ([service.SERV_UUID isEqual:self->serv_uuid]) {
            service.nickname = @"Me";
        }
        [self->_serviceArray addObject:service];
        NSDictionary *event = @{@"type":@"findService",@"service":service};
        [self.delegate eventFromSayHiManagerCenter:event];
        //[self addServiceToUI:service.fullname];
        NSLog(@"after find service:%@",self->_serviceArray);
        NSDictionary *notif = @{@"title":service.nickname,@"info":@"Online"};
        [self pushNotification:notif onlyHidden:NO];
    });

}
-(void)ServiceBrowerDidRemovedService:(BonjourService *)service{
    dispatch_async(_findServiceQueue, ^{
        for (BonjourService *serv in self->_serviceArray) {
            if ([serv.fullname isEqualToString:service.fullname]) {
                [self->_serviceArray removeObject:serv];
                //[self removeServiceFromUI:service.fullname];
                NSDictionary *event = @{@"type":@"removeService",@"service":serv};
                [self.delegate eventFromSayHiManagerCenter:event];
                NSLog(@"after remove service:%@",self->_serviceArray);
                NSDictionary *notif = @{@"title":service.nickname,@"info":@"Offline"};
                [self pushNotification:notif onlyHidden:NO];
                break;
            }
        }
    });
}
#pragma mark -- Delegate MessageCenterManager
-(void)messageFromCenterManager:(NSDictionary *)msg{
    NSLog(@"message from center:%@",msg);
    NSString *type = [msg objectForKey:@"type"];
    if ([type isEqualToString:@"message"]) {
        NSString *recvMsg = [msg objectForKey:@"content"];
        NSString *serv_uuid = [msg objectForKey:@"serviceUUID"];
        NSLog(@"[RX-msg]:%@ uuid:%@",recvMsg,serv_uuid);
        dispatch_async(_findServiceQueue, ^{
            NSDictionary *event = @{@"type":@"message",@"data":recvMsg,@"serviceUUID":serv_uuid};
            [self.delegate eventFromSayHiManagerCenter:event];
            for (BonjourService *serv in self->_serviceArray) {
                if ([[serv.SERV_UUID UUIDString] isEqualToString:serv_uuid]) {
                    NSDictionary *notif = @{@"title":serv.nickname,@"info":recvMsg};
                    [self pushNotification:notif onlyHidden:YES];
                    break;
                }
            }
            
        });
        //[self printLog:[NSString stringWithFormat:@"[RX]:%@",recvMsg]];
    }
    else if([type isEqualToString:@"upload"]){
        NSString *fileName = [msg objectForKey:@"file"];
        NSString *serv_uuid = [msg objectForKey:@"serviceUUID"];
        NSLog(@"[Upload-file]:%@ uuid:%@",fileName,serv_uuid);
        dispatch_async(_findServiceQueue, ^{
            NSString *content = [NSString stringWithFormat:@"received file:%@",fileName];
            NSDictionary *event = @{@"type":@"message",@"data":content,@"serviceUUID":serv_uuid};
            [self.delegate eventFromSayHiManagerCenter:event];
            for (BonjourService *serv in self->_serviceArray) {
                if ([[serv.SERV_UUID UUIDString] isEqualToString:serv_uuid]) {
                    NSDictionary *notif = @{@"title":serv.nickname,@"info":fileName};
                    [self pushNotification:notif onlyHidden:YES];
                    break;
                }
            }
            
        });
        //[self printLog:[NSString stringWithFormat:@"[Recv-File]:%@",fileName]];
    }
}

@end
