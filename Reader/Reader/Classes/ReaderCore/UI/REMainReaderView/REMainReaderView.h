//
//  REMainReaderView.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REDocument.h"

@protocol REMainReaderViewDelegate;

@interface REMainReaderView : UIView

@property (nonatomic, weak) IBOutlet NSObject <REMainReaderViewDelegate> *delegate;

@property (nonatomic) REDocument *document;

@property (nonatomic) NSMutableArray *attachments;

- (void) needsUpdatePages;

- (NSUInteger) pageCount;
- (NSUInteger) currentPage;

- (void) showNextPage;
- (void) showPreviousPage;
- (void) showPageAtIndex:(NSUInteger)index;

- (NSString *) currentChapterTitle;

- (NSArray *) runs;

@end


@protocol REMainReaderViewDelegate

- (void) readerView:(REMainReaderView *) readerView pageWillChanged:(NSUInteger)pageIndex;
- (void) readerView:(REMainReaderView *) readerView pageDidChanged:(NSUInteger)pageIndex;

@end