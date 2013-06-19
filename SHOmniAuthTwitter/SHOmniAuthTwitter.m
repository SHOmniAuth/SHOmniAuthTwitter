//
//  SHOmniAuthTwitter.m
//  SHAccountManagerExample
//
//  Created by Seivan Heidari on 3/24/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHOmniAuthTwitter.h"
#import "SHOmniAuth.h"

#import "TWAPIManager.h"

#import "OAuthCore.h"
#import "OAuth+Additions.h"

#import "AFOAuth1Client.h"

#import <Accounts/Accounts.h>

#define NSNullIfNil(v) (v ? v : [NSNull null])


@interface SHOmniAuthTwitter ()
+(NSMutableDictionary *)authHashWithResponse:(NSDictionary *)theResponse;

@end


@implementation SHOmniAuthTwitter

+(void)performLoginWithListOfAccounts:(SHOmniAuthAccountsListHandler)accountPickerBlock
                           onComplete:(SHOmniAuthAccountResponseHandler)completionBlock; {
  ACAccountStore * accountStore  =  [[ACAccountStore alloc] init];
  ACAccountType  * accountType   = [accountStore accountTypeWithAccountTypeIdentifier:self.accountTypeIdentifier];
  [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      accountPickerBlock([accountStore accountsWithAccountType:accountType], ^(id<account> theChosenAccount) {
        ACAccount * account = (ACAccount *)theChosenAccount;
        if(account == nil)[self performLoginForNewAccount:completionBlock];
        else [self performReverseAuthForAccount:account withBlock:completionBlock];
      });      
    });
  }];

  
}

+(void)performLoginForNewAccount:(SHOmniAuthAccountResponseHandler)completionBlock; {
  
  
  
  
  AFOAuth1Client *  twitterClient = [[AFOAuth1Client alloc]
                                     initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com/"]
                                     key:[SHOmniAuth providerValue:SHOmniAuthProviderValueKey forProvider:self.provider]
                                     secret:[SHOmniAuth providerValue:SHOmniAuthProviderValueSecret forProvider:self.provider]];
  
  [twitterClient authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token"
                                   userAuthorizationPath:@"oauth/authorize"
                                             callbackURL:[NSURL
                                                          URLWithString:[SHOmniAuth
                                                                         providerValue:SHOmniAuthProviderValueCallbackUrl
                                                                         forProvider:self.provider]]
                                         accessTokenPath:@"oauth/access_token"
                                            accessMethod:@"POST"
                                                   scope:[SHOmniAuth
                                                          providerValue:SHOmniAuthProviderValueScope
                                                          forProvider:self.provider]
                                                 success:^(AFOAuth1Token *accessToken, id responseObject) {
                                              //REMOVE OBSERVER
                                                   NSLog(@"LOOOLZ %@", responseObject);
                                              [self saveTwitterAccountWithToken:accessToken.key andSecret:accessToken.secret
                                                          withCompletionHandler:^(ACAccount *account, NSError *error) {
                                                            if(!error && account == nil)
                                                              completionBlock(nil, nil, error, NO);
                                                            else
                                                              [self performReverseAuthForAccount:account withBlock:completionBlock];
                                                          }];
                                              
                                            } failure:^(NSError *error) {
                                              completionBlock(nil, nil, error, NO);
                                            }];
  
}




+(BOOL)hasLocalAccountOnDevice; {
  return [TWAPIManager isLocalTwitterAccountAvailable];
}


+(void)performReverseAuthForAccount:(ACAccount *)theAccount withBlock:(SHOmniAuthAccountResponseHandler)completionBlock; {
  [TWAPIManager registerTwitterAppKey:[SHOmniAuth providerValue:SHOmniAuthProviderValueKey forProvider:self.provider]
                         andAppSecret:[SHOmniAuth providerValue:SHOmniAuthProviderValueSecret forProvider:self.provider]];
  
  
  ACAccountStore * accountStore  =  [[ACAccountStore alloc] init];
  ACAccountType  * accountType   = [accountStore accountTypeWithAccountTypeIdentifier:self.accountTypeIdentifier];
  theAccount.accountType = accountType; // Apple SDK bug - accountType isn't retained.
  [TWAPIManager performReverseAuthForAccount:theAccount withHandler:^(NSData *responseData, NSError *error) {
    

    
    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    

    NSDictionary * response = [NSURL ab_parseURLQueryString:responseStr];

    
    
    
    BOOL isSuccess = error == nil ? YES : NO;
    
    SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"http://api.twitter.com/1.1/account/verify_credentials.json?include_entities=false&skip_status=true"] parameters:nil];
    request.account = theAccount;
    
    
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
      
      
      NSDictionary * responseUser =  [NSJSONSerialization
                                      JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
      
      NSMutableDictionary * fullResponse = responseUser.mutableCopy;
      fullResponse[@"oauth_token_secret"] = response[@"oauth_token_secret"];
      fullResponse[@"oauth_token"]        = response[@"oauth_token"];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock((id<account>)theAccount, [self authHashWithResponse:fullResponse.copy], error, isSuccess);
      });
      
    }];

}];

  
}

+(void)saveTwitterAccountWithToken:(NSString *)theToken andSecret:(NSString *)theSecret
             withCompletionHandler:(void (^)(ACAccount * account, NSError * error))onCompletionBlock; {
  
  ACAccountStore * accountStore  =  [[ACAccountStore alloc] init];
  ACAccountType  * accountType   = [accountStore accountTypeWithAccountTypeIdentifier:self.accountTypeIdentifier];

  ACAccountCredential * credential    = [[ACAccountCredential alloc]
                                         initWithOAuthToken:theToken tokenSecret:theSecret];
  
  __block ACAccount * account = [[ACAccount alloc]
                                 initWithAccountType:accountType];
  account.accountType = accountType; // Apple SDK bug - accountType isn't retained.

  account.credential = credential;
  [accountStore saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
    
    BOOL hasSavedAccount = [accountStore accountsWithAccountType:accountType].count > 0;
    if ([error.domain isEqualToString:ACErrorDomain] && error.code ==ACErrorAccountAlreadyExists) {
      NSArray * accounts = [accountStore accountsWithAccountType:accountType];
      if(accounts.count > 0)
        account = accounts[0];
      else
        account = nil;
    }
    
    else if (success == NO)
      account = nil;
    //[self logErrorCode:error];

    dispatch_async(dispatch_get_main_queue(), ^{ onCompletionBlock(account, error); });
    
  }];
  
  
  
  
  
  
}


+(NSString *)provider; {
  return self.description;
}

+(NSString *)accountTypeIdentifier; {
  return ACAccountTypeIdentifierTwitter;
}

+(NSString *)serviceType; {
  return SLServiceTypeTwitter;
}

+(NSString *)description; {
  return NSStringFromClass(self.class);
}
+(NSMutableDictionary *)authHashWithResponse:(NSDictionary *)theResponse; {
  NSString * name  = theResponse[@"name"];
  NSArray  * names = [name componentsSeparatedByString:@" "];
  NSString * firstName = nil;
  NSString * lastName = nil;
  if(names.count > 0 )
    firstName = names[0];
  if(names.count > 1 )
    lastName = names[1];
  if(names.count > 2 )
    lastName = names[names.count-1];
  
    NSString * publicProfile = [NSString stringWithFormat:@"%@/%@", @"https://twitter.com", theResponse[@"screen_name"]];

    NSMutableDictionary * omniAuthHash = @{@"auth" :@{
                                               @"credentials" : @{@"secret" : NSNullIfNil(theResponse[@"oauth_token_secret"]),
                                                                  @"token"  : NSNullIfNil(theResponse[@"oauth_token"])
                                                                  }.mutableCopy,
                                  
                                               @"info"        : @{@"description" : NSNullIfNil(theResponse[@"description"]),
                                                                  @"email"       : NSNullIfNil(theResponse[@"email"]),
                                                                  @"first_name"  : NSNullIfNil(firstName),
                                                                  @"last_name"   : NSNullIfNil(lastName),
                                                                  @"headline"    : NSNullIfNil(theResponse[@"headline"]),
                                                                  @"image"       : NSNullIfNil(theResponse[@"profile_image_url"]),
                                                                  @"name"        : NSNullIfNil(name),
                                                                  @"urls"        : @{@"public_profile" : publicProfile,
                                                                                     @"website" : theResponse[@"url"]
                                                                                    }.mutableCopy,
                                              
                                                                  }.mutableCopy,
                                  
                                               @"provider" : @"twitter",
                                               @"uid"      : NSNullIfNil(theResponse[@"id"]),
                                               @"raw_info" : NSNullIfNil(theResponse)
                                               }.mutableCopy,
                                           @"email"    : NSNullIfNil(theResponse[@"email"]),
                                           }.mutableCopy;
  
  
  return omniAuthHash;
}
@end
