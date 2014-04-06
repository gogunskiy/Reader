//
//  REMainReaderView.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REDocument.h"


@interface REMainReaderView : UIScrollView

@property (nonatomic) REDocument *document;

- (void) needsUpdatePages;

- (NSUInteger) pageCount;
- (NSUInteger) currentPage;

- (void) showNextPage;
- (void) showPreviousPage;
- (void) showPageAtIndex:(NSUInteger)index;


@end
