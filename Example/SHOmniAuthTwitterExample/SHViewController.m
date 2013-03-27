//
//  SHViewController.m
//  SHOmniAuthTwitterExample
//
//  Created by Seivan Heidari on 3/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHViewController.h"
#import "SHOmniAuthTwitter.h"
#import "UIActionSheet+BlocksKit.h"
#import "NSArray+BlocksKit.h"
@interface SHViewController ()

@end

@implementation SHViewController

-(void)viewDidAppear:(BOOL)animated; {
  [super viewDidAppear:animated];
  [SHOmniAuthTwitter performLoginWithListOfAccounts:^(NSArray *accounts, SHOmniAuthAccountPickerHandler pickAccountBlock) {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick twitter account"];
    [accounts each:^(id<account> account) {
      [actionSheet addButtonWithTitle:account.username handler:^{
        pickAccountBlock(account);
      }];
    }];
    if(accounts.count < 1)
      pickAccountBlock(nil);
    else {
      [actionSheet addButtonWithTitle:@"Add Account" handler:^{
        pickAccountBlock(nil);
      }];
      [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
   

  } onComplete:^(id<account> account, id response, NSError *error, BOOL isSuccess) {
    NSLog(@"%@", response);
  }];
	
}

@end
