//
//  MainViewController.h
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenuBarViewController.h"
#import "ChatViewController.h"
#import "ContactsViewController.h"
#import "SayHiManagerCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : NSViewController<MenuBarDelegate,ContactsViewDelegate,SayHiManagerCenterDelegate,EventFromChatViewDelegate>
{
    IBOutlet NSSplitView *splitView;
    IBOutlet NSView *leftView;
    IBOutlet NSView *chatView;
}
@end

NS_ASSUME_NONNULL_END
