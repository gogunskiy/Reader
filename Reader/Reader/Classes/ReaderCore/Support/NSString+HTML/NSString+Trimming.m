//
//  NSString+Trimming.m
//  Reader
//
//  Created by gogunsky on 4/27/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "NSString+Trimming.h"

@implementation NSString (Trimming)


- (NSString *)stringByTrimmingLeadingWhitespaceCharacters
{
    return [self stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
}


- (NSString *)stringByTrimmingTrailingWhitespaceCharacters
{
    return [self stringByTrimmingTrailingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound)
    {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

@end
