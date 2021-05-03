//
//  ServiceController.h
//  BonjourFileClient
//
//  Created by weidongcao on 2020/8/20.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dns_sd.h"

@interface ServiceController : NSObject
{
    DNSServiceRef       fServiceRef;
    CFSocketRef         fSocketRef;
    CFRunLoopSourceRef  fRunloopSrc;
}

- (id)initWithServiceRef:(DNSServiceRef)ref;
- (void)addToCurrentRunLoop;
- (DNSServiceRef)serviceRef;
//- (void)dealloc;

@end // interface ServiceController
