//
//  SayHiServer.m
//  SayHiClientTest
//
//  Created by weidongcao on 2020/8/22.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "SayHiServer.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation SayHiServer
{
    HTTPServer *httpServer;
    
}
-(BOOL)initServer:(NSUUID *)uuid{
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    NSString* uploadDirPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"StoreFolder"];
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    
    
    // Initalize our http server
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_SayHiService._tcp."];
    
    NSString *serviceName = [NSString stringWithFormat:@"%@[%@]",NSFullUserName(),uuid];
    [httpServer setName:serviceName];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    //    [httpServer setPort:12345];
    
    // Serve files from the standard Sites folder
    //NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
    //DDLogInfo(@"Setting document root: %@", docRoot);
    
    //[httpServer setDocumentRoot:docRoot];
    
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    
    NSError *error = nil;
    if(![httpServer start:&error])
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
        return NO;
    }
    return YES;
}



@end
