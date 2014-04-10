//
//  REDocument.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REDocument.h"
#import "REChapter.h"

@implementation REDocument

- (instancetype)init
{
    self = [super init];
    
    if (self) 
    {
        [self setChapters:[NSMutableArray new]];
    }
    
    return self;
}

- (NSAttributedString *) attributedString
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    
    for (REChapter *chapter in [self chapters])
    {
        [result appendAttributedString: [chapter attributedString]];
        [result addAttribute:@"END_OF_CHAPTER" value:@1 range:NSMakeRange(result.length - 1, 1)];
    }
    
    return result;
}

@end
