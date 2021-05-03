//
//  ServiceController.m
//  BonjourFileClient
//
//  Created by weidongcao on 2020/8/20.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "ServiceController.h"

@implementation ServiceController : NSObject
{
//    DNSServiceRef        fServiceRef;
//    CFSocketRef          fSocketRef;
//    CFRunLoopSourceRef   fRunloopSrc;
}


- (id)initWithServiceRef:(DNSServiceRef)ref
{
    self = [super init];
    if (self) {
        fServiceRef = ref;
        fSocketRef = NULL;
        fRunloopSrc = NULL;
    }
    return self;
}


- (void)addToCurrentRunLoop
{
    CFSocketContext    context = { 0, (void*)fServiceRef, NULL, NULL, NULL };

    fSocketRef = CFSocketCreateWithNative(kCFAllocatorDefault, DNSServiceRefSockFD(fServiceRef), kCFSocketReadCallBack, ProcessSockData, &context);
    if (fSocketRef) {
        // Prevent CFSocketInvalidate from closing DNSServiceRef's socket.
        CFOptionFlags sockFlags = CFSocketGetSocketFlags(fSocketRef);
        CFSocketSetSocketFlags(fSocketRef, sockFlags & (~kCFSocketCloseOnInvalidate));
        fRunloopSrc = CFSocketCreateRunLoopSource(kCFAllocatorDefault, fSocketRef, 0);
    }
    if (fRunloopSrc) {
        CFRunLoopAddSource(CFRunLoopGetCurrent(), fRunloopSrc, kCFRunLoopDefaultMode);
    } else {
        printf("Could not listen to runloop socket\n");
    }
}


- (DNSServiceRef)serviceRef
{
    return fServiceRef;
}




//- (void)dealloc
//{
//    if (fSocketRef) {
//        CFSocketInvalidate(fSocketRef);        // Note: Also closes the underlying socket
//        CFRelease(fSocketRef);
//
//        // Workaround that gives time to CFSocket's select thread so it can remove the socket from its
//        // FD set before we close the socket by calling DNSServiceRefDeallocate. <rdar://problem/3585273>
//        usleep(1000);
//    }
//
//    if (fRunloopSrc) {
//        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), fRunloopSrc, kCFRunLoopDefaultMode);
//        CFRelease(fRunloopSrc);
//    }
//
//    DNSServiceRefDeallocate(fServiceRef);
//
//    [super dealloc];
//}

static void
ProcessSockData(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    DNSServiceRef serviceRef = (DNSServiceRef)info;
    DNSServiceErrorType err = DNSServiceProcessResult(serviceRef);
    if (err != kDNSServiceErr_NoError) {
        printf("DNSServiceProcessResult() returned an error! %d\n", err);
    }
}

@end
