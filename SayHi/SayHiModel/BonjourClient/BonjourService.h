//
//  BonjourService.h
//  BonjourFileClient
//
//  Created by weidongcao on 2020/8/20.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BonjourService : NSObject

@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *hosttarget;
@property (nonatomic, retain) NSString *servicetype;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *ipV4;
@property (nonatomic, retain) NSString *port;
@property (nonatomic, retain) NSUUID *SERV_UUID;
@property (nonatomic, retain) NSString *nickname;

@end

NS_ASSUME_NONNULL_END
