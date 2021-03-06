//
//  REDocument.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface REDocument : NSObject

@property (nonatomic) NSMutableArray    *chapters;
@property (nonatomic) NSDictionary      *info;

@property (nonatomic) NSMutableAttributedString *attributedString;

- (void) compileAttributedString;

@end
