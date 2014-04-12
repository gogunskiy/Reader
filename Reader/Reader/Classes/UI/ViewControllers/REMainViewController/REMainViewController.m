//
//  REMainViewController.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REMainViewController.h"
#import "REReaderController.h"
#import "REMainReaderView.h"

@interface REMainViewController ()

@property (nonatomic, weak) IBOutlet REMainReaderView *readerView;
@property (nonatomic, weak) IBOutlet UILabel *pageCountLabel;
@property (nonatomic, weak) IBOutlet UISlider *pageSlider;
@property (nonatomic, weak) IBOutlet UILabel *bookTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *chapterTitleLabel;

@property (nonatomic, weak) IBOutlet UIView *topLineDivider;


@property (nonatomic, assign) BOOL toolbarModeEnabled;


@property (nonatomic, assign) NSTimeInterval lastTimeWhenPageProgressWasUpdated;

@end

@implementation REMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *bookPath = [[NSBundle mainBundle] resourcePath];
    bookPath = [bookPath stringByAppendingPathComponent:[self documentInfo][@"file"]];
    
    
    [READER loadDocumentWithPath:bookPath
                 completionBlock:^(REDocument *document)
    {
        [[self readerView] setDocument:document];
        [[self readerView] needsUpdatePages];
        [self updateUI];
    } 
                      errorBlock:^(NSError *error)
    {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:TRUE animated:TRUE];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:FALSE animated:TRUE];
    [super viewWillDisappear:animated];
}

- (void) updateUI
{
    [self updatePageSlider];
    [self updateProgressLabels];
    [self updateElemnentsVisibility];
}

- (void) updatePageSlider
{
    [[self pageSlider] setMaximumValue:self.readerView.pageCount];
    [[self pageSlider] setValue:self.readerView.currentPage animated:TRUE];
}

- (void) updateProgressLabels
{
    NSTimeInterval time = CACurrentMediaTime();
    
    [[self pageCountLabel] setText:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.readerView.currentPage, (unsigned long)self.readerView.pageCount]];
    [[self bookTitleLabel] setText:[self documentInfo][@"title"]];

    if (time - _lastTimeWhenPageProgressWasUpdated > 0.2)
    {
        [[self chapterTitleLabel] setText:self.readerView.currentChapterTitle];
        [self setLastTimeWhenPageProgressWasUpdated:time];
    }
}

- (void) updateElemnentsVisibility
{
    [[self pageCountLabel] setAlpha:1.0];
    
    [UIView animateWithDuration:.5
                     animations:^
     {
         self.topLineDivider.alpha =
         self.pageSlider.alpha =
         self.bookTitleLabel.alpha =
         self.chapterTitleLabel.alpha = [self toolbarModeEnabled] ? 1.0 : 0.0;
     }];
}

#pragma mark - Actions -

- (IBAction) sliderValueDidChanged:(UISlider *)sender
{
    NSUInteger frameIndex = (int)sender.value;
    
    [[self readerView] showPageAtIndex:frameIndex];
    [self updateProgressLabels];
}

- (IBAction) leftSwipe:(UIGestureRecognizer *)sender
{
    [[self readerView] showNextPage];
    
    [self updateProgressLabels];
    [self updatePageSlider];
}

- (IBAction) rightSwipe:(UIGestureRecognizer *)sender
{
    [[self readerView] showPreviousPage];
    
    [self updateProgressLabels];
    [self updatePageSlider];
}

- (IBAction) tap:(UIGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:[self view]];
    CGRect frame  = [[self view] frame];
    
    if (point.x < frame.size.width * 0.25)
    {
        [self rightSwipe:nil];
    }
    else  if (point.x < frame.size.width * 0.75)
    {
        _toolbarModeEnabled = !_toolbarModeEnabled;
        [self updateElemnentsVisibility];
    }
    else
    {
        [self leftSwipe:nil];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // TO DO :
}

@end
