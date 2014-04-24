//
//  RETextElement.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/24/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "HTMLNode.h"

@interface RETextElement : NSObject

@property (nonatomic, strong) id paragraphStyle;
@property (nonatomic) NSString * fontName;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic) NSMutableArray *children;


@property (nonatomic) HTMLNode *node;


@property (nonatomic) NSString * imagesPath;
@property (nonatomic) NSDictionary * css;
@property (nonatomic) NSMutableDictionary * attributes;
@property (nonatomic) NSString * text;
@property (nonatomic) UIColor *color;
@property (nonatomic, assign) CTTextAlignment aligment;

- (NSMutableAttributedString *) attributedString;

@end
