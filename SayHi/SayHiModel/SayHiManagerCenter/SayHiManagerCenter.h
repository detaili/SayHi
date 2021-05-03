//
//  SayHiManagerCenter.h
//  SayHi
//
//  Created by weidongcao on 2020/8/25.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceBrower.h"
#import "HttpPostController.h"
#import "MessageCenterManager.h"
#import "SayHiServer.h"
#import "JsonParser.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SayHiManagerCenterDelegate <NSObject>

-(void)eventFromSayHiManagerCenter:(NSDictionary *)event;

@end

@interface SayHiManagerCenter : NSObject<ServiceBrowerDelegate,MessageCenterManagerDelegate,NSUserNotificationCenterDelegate>

@property (weak) id<SayHiManagerCenterDelegate> delegate;

-(void)initManager;

-(void)sendTo:(BonjourService *)service msg:(NSString *)txt;
-(void)sendTo:(BonjourService *)service file:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
