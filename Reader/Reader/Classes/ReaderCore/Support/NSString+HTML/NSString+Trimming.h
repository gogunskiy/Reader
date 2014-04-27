//
//  NSString+Trimming.h
//  Reader
//
//  Created by gogunsky on 4/27/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Trimming)

- (NSString *)stringByTrimmingLeadingWhitespaceCharacters;
- (NSString *)stringByTrimmingTrailingWhitespaceCharacters;
@end
