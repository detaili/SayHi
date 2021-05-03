//
//  SayHiServer.h
//  SayHiClientTest
//
//  Created by weidongcao on 2020/8/22.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"


NS_ASSUME_NONNULL_BEGIN

@interface SayHiServer : NSObject

-(BOOL)initServer:(NSUUID *)uuid;

@end

NS_ASSUME_NONNULL_END
