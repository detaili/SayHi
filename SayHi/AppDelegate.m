//
//  AppDelegate.m
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property MainViewController *mainVC;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.window.titleVisibility = NSWindowTitleHidden;
    // 设置标题栏透明
    self.window.titlebarAppearsTransparent = YES;
    // 设置contentview与titlebar融合到一起（此时设置背景颜色也将影响titlebar的颜色）
    self.window.styleMask = self.window.styleMask | NSWindowStyleMaskFullSizeContentView;
    //[self.window setOpaque:NO];
    //[self.window setBackgroundColor:[NSColor colorWithCalibratedRed:0.5f green:0.8f blue:0.9f alpha:0.9]];  //背景色
    //[self.window setBackgroundColor:[NSColor windowBackgroundColor]];
    //[[self.window standardWindowButton:NSWindowZoomButton] setEnabled:NO];
    //[[self.window standardWindowButton:NSWindowMiniaturizeButton] setEnabled:NO];
    //self.window.alphaValue = 0.98;
    //毛玻璃效果
    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.window.contentView.bounds];
    visualEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    visualEffectView.material = 0x0;
    visualEffectView.blendingMode = 0x0;
    //visualEffectView.state = NSVisualEffectStateActive;
    [self.window.contentView addSubview:visualEffectView];
    
    self.mainVC = [[MainViewController alloc] init];
    self.mainVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.mainVC.view setFrameSize:self.window.contentView.frame.size];
    [self.window.contentView addSubview:self.mainVC.view];
    
    NSLog(@"launch done");
}

- (void)applicationWillHide:(NSNotification *)notification{
    NSLog(@"app will hide");
}
- (void)applicationWillUnhide:(NSNotification *)notification{
    NSLog(@"app will unhide");
}
- (void)applicationWillBecomeActive:(NSNotification *)notification{
    NSLog(@"app will become active:%hhd",[[NSApplication sharedApplication] isActive]);
}
- (void)applicationWillResignActive:(NSNotification *)notification{
    NSLog(@"app will resign active:%hhd",[[NSApplication sharedApplication] isActive]);
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)windowShouldClose:(NSWindow *)sender{
    NSLog(@"window should close...");
    [NSApp terminate:self];

    return YES;
}
@end
