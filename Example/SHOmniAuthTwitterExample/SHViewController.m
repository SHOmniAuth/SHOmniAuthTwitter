//
//  SHViewController.m
//  SHOmniAuthTwitterExample
//
//  Created by Seivan Heidari on 3/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHViewController.h"
#import "SHOmniAuthTwitter.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "UIAlertView+SHAlertViewBlocks.h"
#import "NSArray+SHFastEnumerationProtocols.h"
@interface SHViewController ()

@end

@implementation SHViewController

-(void)viewDidAppear:(BOOL)animated; {
  [super viewDidAppear:animated];
  [SHOmniAuthTwitter performLoginWithListOfAccounts:^(NSArray *accounts, SHOmniAuthAccountPickerHandler pickAccountBlock) {
    UIActionSheet * actionSheet = [UIActionSheet SH_actionSheetWithTitle:@"Pick your twitter account"];
    [accounts SH_each:^(id<account> account) {
      [actionSheet SH_addButtonWithTitle:account.username withBlock:^(NSInteger theButtonIndex) {
        pickAccountBlock(account);
      }];
    }];
    NSString * buttonTitle = nil;
    if(accounts.count > 0)
      buttonTitle = @"Add account";
    else
      buttonTitle = @"Connect with Twitter";
    
    [actionSheet SH_addButtonWithTitle:buttonTitle withBlock:^(NSInteger theButtonIndex) {
      pickAccountBlock(nil);
    }];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  
   

  } onComplete:^(id<account> account, id response, NSError *error, BOOL isSuccess) {
    NSLog(@"%@", response);
    [[UIAlertView SH_alertViewWithTitle:nil withMessage:response] show];
  }];
	
}

@end
