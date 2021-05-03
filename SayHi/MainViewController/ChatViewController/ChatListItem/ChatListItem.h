//
//  ChatListItem.h
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatListItem : NSTableCellView
{  
}

@property (weak) IBOutlet NSImageView *photoImageView;
@property (weak) IBOutlet NSTextField *nameLabelField;
@property (weak) IBOutlet NSTextField *lastMsgLabelField;
@property (weak) IBOutlet NSImageView *unReadFlagIV;
@end

NS_ASSUME_NONNULL_END
