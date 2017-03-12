//
//  NSString+MessageDigest.m
//  汕大生活助手
//
//  Created by boxytt on 2017/2/26.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+MessageDigest.h"
#import <CommonCrypto/CommonCrypto.h>
typedef unsigned char *(*MessageDigestFuncPtr)(const void *data, CC_LONG len, unsigned char *md);
static NSString *_getMessageDigest(NSString *string, MessageDigestFuncPtr fp, NSUInteger length)
{
    const char *cString = [string UTF8String];
    unsigned char *digest = malloc(sizeof(unsigned char) * length);
    fp(cString, (CC_LONG)strlen(cString), digest);
    NSMutableString *hash = [NSMutableString stringWithCapacity:length * 2];
    
    for (int i = 0; i < length; ++i) {
        [hash appendFormat:@"%02x", digest[i]];
    }
    free(digest);
    
    return [hash lowercaseString];
    
}
@implementation NSString (MessageDigest)
- (NSString *)sha1
{
    return _getMessageDigest(self, CC_SHA1, CC_SHA1_DIGEST_LENGTH);
    
}

@end


