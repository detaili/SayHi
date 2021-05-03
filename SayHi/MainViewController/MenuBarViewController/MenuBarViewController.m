//
//  MenuBarViewController.m
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "MenuBarViewController.h"

@interface MenuBarViewController ()

@end

@implementation MenuBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[NSColor darkGrayColor].CGColor];
}

-(IBAction)msgBtnAction:(id)sender{
    NSDictionary *msg = @{@"type":@"click",@"button":@"message"};
    [self.delegate eventFromMenuBarView:msg];
}
-(IBAction)contactBtnAction:(id)sender{
    NSDictionary *msg = @{@"type":@"click",@"button":@"contact"};
    [self.delegate eventFromMenuBarView:msg];
}
-(IBAction)configBtnAction:(id)sender{
    NSDictionary *msg = @{@"type":@"click",@"button":@"config"};
    [self.delegate eventFromMenuBarView:msg];
}

@end
