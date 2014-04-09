//
//  REAttributedElement.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface REAttributedElement : NSObject



@property (nonatomic) REAttributedElement *parent;

@property (nonatomic, assign) CTParagraphStyleRef paragraphStyle;
@property (nonatomic) NSString * fontName;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic) NSMutableArray *children;

@property (nonatomic) NSString * name;
@property (nonatomic) NSDictionary * attributes;
@property (nonatomic) NSString * text;
@property (nonatomic) UIColor *color;

@property (nonatomic) NSMutableAttributedString *attributedString;
@property (nonatomic) NSMutableArray *attachments;

- (void) apply;

@end
