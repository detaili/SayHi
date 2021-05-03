//
//  ChatViewController.h
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BonjourService.h"
#import "ChatListItem.h"
#import "MessageViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol EventFromChatViewDelegate <NSObject>

-(void)eventFromChatView:(NSDictionary *)event;

@end
@interface ChatViewController : NSViewController<EventFromMessageViewDelegate>
{
    IBOutlet NSSearchField *searchField;
    IBOutlet NSButton *addBtn;
    IBOutlet NSTableView *chatListTableView;

    
    IBOutlet NSSplitView *mainSplitView;
    
    IBOutlet NSSplitView *msgSplitView;
    IBOutlet NSView *messageView;
}

@property (nonatomic, retain) NSMutableArray *chatServiceArr;
@property (weak) id<EventFromChatViewDelegate> delegate;

-(void)initChatView;

-(IBAction)addBtnAction:(id)sender;
-(void)removedChatService:(BonjourService *)service;
-(void)updateSelectService:(BonjourService *)service;
-(void)receivedMsg:(NSDictionary *)msg fromService:(BonjourService *)serv;

@end

NS_ASSUME_NONNULL_END
