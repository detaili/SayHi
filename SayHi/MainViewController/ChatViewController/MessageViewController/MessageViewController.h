//
//  MessageViewController.h
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BonjourService.h"
#import "UploadFileViewController.h"
//#import "MyInputField.h"
NS_ASSUME_NONNULL_BEGIN
@protocol EventFromMessageViewDelegate <NSObject>

-(void)eventFromMessageView:(NSDictionary *)event;

@end
@interface MessageViewController : NSViewController<UploadFileViewDelegate>
{
    IBOutlet NSTextField *nameLabelField;
    IBOutlet NSImageView *photoImageView;
    IBOutlet NSTableView *msgListTableView;
    IBOutlet NSButton *uploadFileBtn;
    IBOutlet NSTextField *inputTextField;
}

@property (nonatomic, retain) NSString *myNickName;
@property (weak) id<EventFromMessageViewDelegate> delegate;

-(IBAction)inputTextFieldAction:(id)sender;

-(void)initMsgView;
//msg item: {"from":"me","timestamp":"2020/08/25 20:00:00","content":"who are you?","status":"OK"}
-(void)receivedMsg:(NSDictionary *)msg;
-(void)updateService:(BonjourService *)serv msgListArr:(NSArray * _Nullable )msgArr;
-(void)disabledCurrentMsg;
@end

NS_ASSUME_NONNULL_END
