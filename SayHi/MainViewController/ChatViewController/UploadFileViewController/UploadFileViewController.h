//
//  UploadFileViewController.h
//  SayHi
//
//  Created by weidongcao on 2020/8/27.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@protocol UploadFileViewDelegate <NSObject>

-(void)eventFromUploadFileView:(NSDictionary *)event;

@end

@interface UploadFileViewController : NSViewController
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSTextField *filePathField;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *statusLabel;
    IBOutlet NSButton *sendBtn;
}

@property (weak) id<UploadFileViewDelegate> delegate;
@property (nonatomic, retain) NSString *serviceNickName;

-(IBAction)backBtnAction:(id)sender;
-(IBAction)sendBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
