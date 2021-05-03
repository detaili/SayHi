//
//  MessageCenterManager.h
//  BonjourFileServer
//
//  Created by weidongcao on 2020/8/21.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MessageCenterManagerDelegate <NSObject>

-(void)messageFromCenterManager:(NSDictionary *)msg;

@end

@interface MessageCenterManager : NSObject
+ (id)sharedInstance;

@property (weak) id<MessageCenterManagerDelegate> delegate;

-(void)initManager;
-(void)pushMessage:(NSDictionary *)msg;

@end

NS_ASSUME_NONNULL_END
