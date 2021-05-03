//
//  MsgListItem.h
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MsgListItemMe: NSTableCellView

@property (weak) IBOutlet NSTextField *titleLabelField;
@property (weak) IBOutlet NSTextField *contentField;

@end

NS_ASSUME_NONNULL_END
