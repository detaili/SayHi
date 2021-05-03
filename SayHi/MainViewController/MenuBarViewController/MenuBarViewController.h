//
//  MenuBarViewController.h
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MenuBarDelegate <NSObject>

-(void)eventFromMenuBarView:(NSDictionary *)event;

@end

@interface MenuBarViewController : NSViewController
{
    IBOutlet NSButton *msgBtn;
    IBOutlet NSButton *contactBtn;
    IBOutlet NSButton *configBtn;
}

@property (weak) id<MenuBarDelegate> delegate;

-(IBAction)msgBtnAction:(id)sender;
-(IBAction)contactBtnAction:(id)sender;
-(IBAction)configBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
