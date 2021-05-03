//
//  JsonParser.h
//  SayHiClientTest
//
//  Created by weidongcao on 2020/8/21.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonParser : NSObject
+ (NSDictionary*)parseJSonStr:(NSString *)jsonString;
+ (NSString *)getJsonStringWithDict:(NSDictionary *)jsonDict;
@end

NS_ASSUME_NONNULL_END
