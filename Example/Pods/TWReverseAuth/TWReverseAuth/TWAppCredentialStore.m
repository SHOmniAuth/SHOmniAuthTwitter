//
//  TWAppCredentialStore.m
//  TWReverseAuthExample
//
//  Created by Seivan Heidari on 3/13/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "TWAppCredentialStore.h"
#import "LUKeychainAccess.h"

#define kTWAppKey    @"TWAppKey"
#define kTWAppSecret @"TWAppSecret"
#define kTWKeychainKey NSStringFromClass(self.class)
@implementation TWAppCredentialStore
+(void)registerTwitterAppKey:(NSString *)theAppKey andAppSecret:(NSString *)theAppSecret; {
  NSAssert(theAppKey, @"You need to pass the Twitter App Key");
  NSAssert(theAppSecret, @"You need to pass the Twitter App Secret");
  LUKeychainAccess * keychain = [LUKeychainAccess standardKeychainAccess];
  
  NSDictionary * credential = @{ kTWAppKey    : theAppKey,
                                 kTWAppSecret : theAppSecret};
  [keychain setObject:credential forKey:kTWKeychainKey];
}

+(NSString *)twitterAppKey; {
  NSDictionary * credential = [[LUKeychainAccess standardKeychainAccess] objectForKey:kTWKeychainKey];
  
  return credential[kTWAppKey];
}

+(NSString *)twitterAppSecret; {
  NSDictionary * credential = [[LUKeychainAccess standardKeychainAccess] objectForKey:kTWKeychainKey];
  
  return credential[kTWAppSecret];
}

@end
