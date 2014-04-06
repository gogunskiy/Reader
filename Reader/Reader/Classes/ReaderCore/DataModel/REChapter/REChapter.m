//
//  REChapter.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REChapter.h"

@implementation REChapter

- (instancetype)init
{
    self = [super init];
    
    if (self) 
    {
        [self setAttachments:[NSMutableArray new]];
    }
    
    return self;
}

@end
