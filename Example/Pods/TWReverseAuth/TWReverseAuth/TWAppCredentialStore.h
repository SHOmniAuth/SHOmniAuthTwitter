//
//  TWAppCredentialStore.h
//  TWReverseAuthExample
//
//  Created by Seivan Heidari on 3/13/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWAppCredentialStore : NSObject
+(void)registerTwitterAppKey:(NSString *)theAppKey andAppSecret:(NSString *)theAppSecret;
+(NSString *)twitterAppKey;
+(NSString *)twitterAppSecret;
@end
