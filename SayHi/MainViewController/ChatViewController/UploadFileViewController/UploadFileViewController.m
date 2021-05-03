//
//  UploadFileViewController.m
//  SayHi
//
//  Created by weidongcao on 2020/8/27.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "UploadFileViewController.h"

@interface UploadFileViewController ()

@end

@implementation UploadFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
-(void)viewWillAppear{
    [progressIndicator stopAnimation:self];
    [statusLabel setStringValue:@""];
    [filePathField setStringValue:@""];
    [titleLabel setStringValue:[NSString stringWithFormat:@"Upload File To %@",self.serviceNickName]];
    
    //创建通知中心对象
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //注册、接收通知
    [center addObserver:self selector:@selector(updateUploadResult:) name:@"sayhi.uploadfileresponse.notification" object:nil];
}
-(void)viewWillDisappear{
    //在页面消失的回调方法中移除通知。
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sayhi.uploadfileresponse.notification"object:nil];
}
-(void)updateUploadResult:(NSNotification *)noti{
    NSDictionary *infoDict = [noti userInfo];
    NSLog(@"[UploadVC]upload response:%@",infoDict);
    NSString *response = [infoDict objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->progressIndicator stopAnimation:self];
        [self->statusLabel setStringValue:response];
    });
}
-(IBAction)backBtnAction:(id)sender{
    [self dismissViewController:self];
}
-(IBAction)sendBtnAction:(id)sender{
    [statusLabel setStringValue:@""];
    NSString *filePath = [filePathField stringValue];
    if ([filePath length] == 0) {
        [statusLabel setStringValue:@"Error:file path is empty!"];
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath] == NO) {
        [statusLabel setStringValue:@"Error:file is not exists!"];
        return;
    }
    NSDictionary *event = @{@"type":@"upload",@"file":filePath};
    [self.delegate eventFromUploadFileView:event];
    [progressIndicator startAnimation:self];
    [statusLabel setStringValue:@"please wait,uploading..."];
}

@end
