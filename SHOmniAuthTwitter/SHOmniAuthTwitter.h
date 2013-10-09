//
//  SHOmniAuthTwitter.h
//  SHAccountManagerExample
//
//  Created by Seivan Heidari on 3/24/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

static NSString * const kOmniAuthTwitterErrorDomain                    = @"SHOmniAuthTwitter";
static NSString * const kOmniAuthTwitterErrorDomainConflictingAccounts = @"SHOmniAuthTwitterConflictingAccounts";
static NSString * const kOmniAuthTwitterErrorDomainAccessNotGranted    = @"kOmniAuthTwitterErrorDomainAccessNotGranted";

static const NSInteger kOmniAuthTwitterErrorCodeConflictingAccounts = 500;
static const NSInteger kOmniAuthTwitterErrorCodeAccessNotGranted = 403;

static NSString * const kOmniAuthTwitterUserInfoKeyOverrideExistingAccount = @"SHOmniAuthTwitterUserInfoKeyOverrideExistingAccount";

#import "SHOmniAuthProvider.h"
@interface SHOmniAuthTwitter : NSObject
<SHOmniAuthProvider>
@end
