//
//  ServiceBrower.h
//  BonjourFileClient
//
//  Created by weidongcao on 2020/8/20.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BonjourService.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ServiceBrowerDelegate <NSObject>

-(void)ServiceBrowerDidFindService:(BonjourService *)service;
-(void)ServiceBrowerDidRemovedService:(BonjourService *)service;

@end

@interface ServiceBrower : NSObject<NSNetServiceBrowserDelegate>

@property (weak) id<ServiceBrowerDelegate> delegate;

-(void)initBrower;
-(void)startSearch:(NSString *)serviceType domain:(NSString *)domain;

@end

NS_ASSUME_NONNULL_END
