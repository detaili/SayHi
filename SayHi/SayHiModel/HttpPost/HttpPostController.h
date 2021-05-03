//
//  HttpPostController.h
//  SayHiClientTest
//
//  Created by weidongcao on 2020/8/21.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpPostController : NSObject

@property (nonatomic, retain) NSUUID *SERV_UUID;

-(NSString *)uploadTo:(NSString *)serverUrl
             withFile:(NSString *)filePath
              timeout:(NSTimeInterval )to
                error:(NSError *__strong*)err;

-(NSString *)sendMessageTo:(NSString *)serverUrl
                   message:(NSString *)msg
                   timeout:(NSTimeInterval )to
                     error:(NSError *__strong*)err;

@end

NS_ASSUME_NONNULL_END
