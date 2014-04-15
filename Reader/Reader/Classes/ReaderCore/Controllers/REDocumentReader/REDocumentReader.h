//
//  REMainReaderView.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REDocument.h"
#import <CoreText/CoreText.h>

@protocol REMainReaderDelegate;

@interface REDocumentReader : NSObject

@property (nonatomic, weak) IBOutlet NSObject <REMainReaderDelegate> *delegate;

@property (nonatomic, assign) NSInteger currentFrame;

@property (nonatomic) REDocument *document;

@property (nonatomic) NSMutableArray *attachments;

- (void) needsUpdatePagesWithFrame:(CGRect)frame;

- (NSUInteger) framesCount;

- (CTFrameRef) cTFrameAtIndex:(NSInteger)index;

- (NSString *) currentChapterTitle;

@end


@protocol REMainReaderDelegate

- (void) reader:(REDocumentReader *) reader pageWillChanged:(NSUInteger)pageIndex;
- (void) reader:(REDocumentReader *) reader pageDidChanged:(NSUInteger)pageIndex;

@end