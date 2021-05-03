//
//  ContactsViewController.h
//  SayHi
//
//  Created by weidongcao on 2020/8/24.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BonjourService.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ContactsViewDelegate <NSObject>

-(void)eventFromContactsView:(NSDictionary *)event;

@end

@interface ContactsViewController : NSViewController
{
    IBOutlet NSSearchField *searchField;
    IBOutlet NSTableView *serviceListTableView;
}

@property NSMutableArray *serviceListArr;

@property (weak) id<ContactsViewDelegate> delegate;

-(void)initView;

-(void)addServiceItem:(BonjourService *)service;
-(void)removeServiceItem:(BonjourService *)service;

@end

NS_ASSUME_NONNULL_END
