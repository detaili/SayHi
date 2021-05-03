//
//  ServiceBrower.m
//  BonjourFileClient
//
//  Created by weidongcao on 2020/8/20.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "ServiceBrower.h"
#import "dns_sd.h"
#import "ServiceController.h"
#include "stdio.h"

@implementation ServiceBrower
{
    NSNetServiceBrowser *_serviceBrowser;
    ServiceController *_serviceResolver;
    //BonjourService *_findService;
    dispatch_queue_t _findServiceQueue;
    NSMutableDictionary *_allFindServicesDict;
}
-(void)initBrower{
    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [_serviceBrowser setDelegate:self];
    _findServiceQueue = dispatch_queue_create("servicebrower.find.queue", DISPATCH_QUEUE_SERIAL);
    _allFindServicesDict = [[NSMutableDictionary alloc] init];
}
- (void)startSearch:(NSString *)serviceType domain:(NSString *)domain
{
    
    [_serviceBrowser stop];
    [_serviceBrowser searchForServicesOfType:serviceType inDomain:@"local."];
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict
{
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    
    NSString * host = service.name;
    NSLog(@"host: %@", host);
    
    [self resolveInto:service];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    //NSLog(@"removed domain:%@",domainString);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"removed service:%@ type:%@ domain:%@",service.name,service.type,service.domain);
    NSString *fullname = [NSString stringWithFormat:@"%@.%@%@",service.name,service.type,service.domain];
    BonjourService *findService = [_allFindServicesDict objectForKey:fullname];
    [self.delegate ServiceBrowerDidRemovedService:findService];
    [_allFindServicesDict removeObjectForKey:fullname];
    NSLog(@"[brower]after remove service list:%@",_allFindServicesDict);
}


-(void)resolveInto:(NSNetService*)service
{
    if (!service) return;
    
    DNSServiceRef serviceRef;
    DNSServiceErrorType err = DNSServiceResolve(&serviceRef,
                                         (DNSServiceFlags)0,
                               kDNSServiceInterfaceIndexAny,
                  (const char *)[[service name] UTF8String],
                 (const char *)[[service type]  UTF8String],
                (const char *)[[service domain] UTF8String],
                (DNSServiceResolveReply)ServiceResolveReply,
                                                (__bridge void *)(self));
        
    if (kDNSServiceErr_NoError == err) {
        NSLog(@"service0 ref:%d",(unsigned int)serviceRef);
        _serviceResolver = [[ServiceController alloc] initWithServiceRef:serviceRef];
        [_serviceResolver addToCurrentRunLoop];
    }
}

- (void)resolveClientWitHost:(NSArray *)serviceInfo
{
   // _findService.port =serviceInfo[2];
    NSArray *tempArr =[serviceInfo[0] componentsSeparatedByString:@"."];
    NSString *serv_type = [NSString stringWithFormat:@"%@.%@",tempArr[1],tempArr[2]];
    BonjourService *findService = [[BonjourService alloc] init];
    findService.fullname = serviceInfo[0];
    findService.hosttarget = serviceInfo[1];
    NSString *nicknameStr = [serviceInfo[1] componentsSeparatedByString:@"."][0];
    if ([nicknameStr length] > 12) {
        nicknameStr = [nicknameStr substringWithRange:NSMakeRange(0, 12)];
    }
    findService.nickname = nicknameStr;
    findService.port = serviceInfo[2];
    findService.servicetype =serv_type ;
    findService.domain = [NSString stringWithFormat:@"%@.",tempArr[3]];
    NSArray *matchStrArr = [self arrayForRegex:@"(?<=\\[).*?(?=\\])" string:serviceInfo[0]];
    if ([matchStrArr count] > 0) {
        findService.SERV_UUID = [[NSUUID alloc] initWithUUIDString:[matchStrArr objectAtIndex:0]];
    }
    [_allFindServicesDict setObject:findService forKey:findService.fullname];
    
    //[self.delegate jcBrowserDidFoundService:serviceInfo];
}
-(NSMutableArray *)arrayForRegex:(NSString *)regexString string:(NSString *)str
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            NSString *component = [str substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}
-(void)recordFindIpAddress:(NSString *)ipStr hosttarget:(NSString *)target{
    NSLog(@"[brower]after find service list:%@",_allFindServicesDict);
    for (BonjourService *service in [_allFindServicesDict allValues]) {
        if (service.ipV4 == NULL) {
            service.ipV4 = ipStr;
            NSLog(@"find service:%@ fullname:%@ hosttarget:%@",service,service.fullname,target);
            NSLog(@"Record IP = %@",ipStr);
            [self.delegate ServiceBrowerDidFindService:service];
            break;
        }
    }
}
static void
ServiceResolveReply(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode,
    const char *fullname, const char *hosttarget, uint16_t port, uint16_t txtLen, const char *txtRecord, void *context)
{
    if (errorCode == kDNSServiceErr_NoError) {
        NSLog(@"service1 ref:%d",(unsigned int)sdRef);
        NSString *fullNameStr = [NSString stringWithFormat:@"%s", fullname];
        NSString * hosttargetStr = [NSString stringWithFormat:@"%s", hosttarget];
        NSString * portStr = [NSString stringWithFormat:@"%d", ntohs(port)];
        NSLog(@"fullname:%s", fullname);
        NSLog(@"hosttarget:%s", hosttarget);
        NSLog(@"port:%d", ntohs(port));
        
        
        
        NSArray * serviceInfo = [[NSArray alloc] initWithObjects: fullNameStr, hosttargetStr, portStr, nil];
        [(__bridge ServiceBrower*)context resolveClientWitHost:serviceInfo];
        
        DNSServiceErrorType err = DNSServiceQueryRecord
        (
            &sdRef,
            0,
            interfaceIndex,
            hosttarget,
            kDNSServiceType_A,
            kDNSServiceClass_IN,
            ServiceQueryRecordReply,
            context/* may be NULL */
         );
        if (kDNSServiceErr_NoError == err){
            NSLog(@"query record finished!");
            NSLog(@"service2 ref:%d",(unsigned int)sdRef);
            ServiceController *serviceAnswer = [[ServiceController alloc] initWithServiceRef:sdRef];
            [serviceAnswer addToCurrentRunLoop];
        }else{
            NSLog(@"query record failure!");
        }
        
    } else {
        printf("ServiceResolveReply got an error! %d\n", errorCode);
    }
}

static void ServiceQueryRecordReply(
                DNSServiceRef sdRef,
                DNSServiceFlags flags,
                uint32_t interfaceIndex,
                DNSServiceErrorType errorCode,
                const char                          *fullname,
                uint16_t rrtype,
                uint16_t rrclass,
                uint16_t rdlen,
                const void                          *rdata,
                uint32_t ttl,
                void                                *context
                )
{
    NSLog(@"query reply...");
    printf("len:%d\n",rdlen);
    if (errorCode == kDNSServiceErr_NoError){
        if (rrtype == kDNSServiceType_A) {
            NSString *hosttarget = [NSString stringWithFormat:@"%s", fullname];
            const unsigned char *digits = rdata;
            if (rdlen == 4) {
                NSString *ipStr = [NSString stringWithFormat:@"%d.%d.%d.%d",digits[0],digits[1], digits[2], digits[3]];
                printf("IP = %d.%d.%d.%d\n", digits[0], digits[1], digits[2], digits[3]);

                [(__bridge ServiceBrower*)context recordFindIpAddress:ipStr hosttarget:hosttarget];
            }
        }
        
    }else{
        NSLog(@"query reply error!");
    }
    
    
    
    
    
}
@end
