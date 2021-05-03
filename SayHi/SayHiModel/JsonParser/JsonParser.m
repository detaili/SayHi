//
//  JsonParser.m
//  SayHiClientTest
//
//  Created by weidongcao on 2020/8/21.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "JsonParser.h"

@implementation JsonParser
+ (NSDictionary*)parseJSonStr:(NSString *)jsonString
{
    NSError *error = nil;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *pureJsonDict = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    
//    NSString *command = [pureJsonDict valueForKey:@"Command"];
    return pureJsonDict;
}


+ (NSString *)getJsonStringWithDict:(NSDictionary *)jsonDict
{
    
    NSData *tempData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:0
                                                         error:nil];
    
    return [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
}
@end
