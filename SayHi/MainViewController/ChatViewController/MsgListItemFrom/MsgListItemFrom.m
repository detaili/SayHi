//
//  MsgListItem.m
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "MsgListItemFrom.h"

@implementation MsgListItemFrom

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    //NSString *msgStr = [msg objectForKey:@"content"];
//    NSUInteger len =  [self.contentField.stringValue length];
//    //NSLog(@"[MsgItem]content len:%ld",len);
//    NSRect fieldrect =  self.contentField.frame;
//    NSLog(@"[MsgItem]fieldSize w:%f h:%f",fieldrect.size.width,fieldrect.size.height);
//    if (len > 45) {
//        CGFloat add_h = (len / 45) * 28;
//        //NSLog(@"add height:%f",add_h);
//        NSRect rect = NSMakeRect(fieldrect.origin.x, fieldrect.origin.y, fieldrect.size.width, 28 +add_h);
//        [self.contentField setFrameSize:NSMakeSize(self.contentField.frame.size.width,self.contentField.frame.size.height + add_h)];
//        [self.contentField setFrame:rect];
//    }
    //[self.contentField setStringValue:msgStr];
}

@end
