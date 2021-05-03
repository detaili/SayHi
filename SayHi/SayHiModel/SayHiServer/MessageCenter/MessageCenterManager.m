//
//  MessageCenterManager.m
//  BonjourFileServer
//
//  Created by weidongcao on 2020/8/21.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "MessageCenterManager.h"

@implementation MessageCenterManager
{
    dispatch_queue_t messageQueue;
}
static MessageCenterManager* _instance = nil;

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
     
    return _instance ;
}
 
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [MessageCenterManager sharedInstance] ;
}
 
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [MessageCenterManager sharedInstance] ;
}

-(void)initManager{
    messageQueue = dispatch_queue_create("messageCenter.queue", DISPATCH_QUEUE_SERIAL);
}
-(void)pushMessage:(NSDictionary *)msg{
    dispatch_async(messageQueue, ^{
        [self.delegate messageFromCenterManager:msg];
    });
}
@end
