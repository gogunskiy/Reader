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

@interface REMainReader : NSObject

@property (nonatomic, weak) IBOutlet NSObject <REMainReaderDelegate> *delegate;

@property (nonatomic) REDocument *document;

@property (nonatomic) NSMutableArray *attachments;

- (void) needsUpdatePagesWithFrame:(CGRect)frame;

- (NSUInteger) pageCount;
- (NSUInteger) currentPage;

- (CTFrameRef) currentCTFrame;

- (void) showNextPage;
- (void) showPreviousPage;
- (void) showPageAtIndex:(NSUInteger)index;

- (NSString *) currentChapterTitle;

- (NSArray *) runs;

@end


@protocol REMainReaderDelegate

- (void) reader:(REMainReader *) reader pageWillChanged:(NSUInteger)pageIndex;
- (void) reader:(REMainReader *) reader pageDidChanged:(NSUInteger)pageIndex;

@end