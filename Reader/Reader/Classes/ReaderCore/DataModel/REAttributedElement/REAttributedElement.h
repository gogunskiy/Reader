//
//  REAttributedElement.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface REAttributedElement : NSObject

@property (nonatomic) REAttributedElement *parent;
@property (nonatomic) NSArray *children;

@property (nonatomic) NSString * name;
@property (nonatomic) NSString * text;
@property (nonatomic) UIFont * font;
@property (nonatomic) UIColor *color;

@property (nonatomic) NSNumber *bold;
@property (nonatomic) NSNumber *italic;
@property (nonatomic) NSNumber *underlined;

@end