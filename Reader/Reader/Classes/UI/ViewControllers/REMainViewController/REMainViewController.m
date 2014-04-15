//
//  REMainViewController.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REMainViewController.h"
#import "REReaderController.h"
#import "RESelectionTool.h"
#import "REPageViewController.h"
#import "REPageView.h"

@interface REMainViewController ()

@property (nonatomic, weak) IBOutlet UIView *pageControllerViewPlaceHolder;
@property (nonatomic, weak) IBOutlet UIView *readerViewPlaceHolder;
@property (nonatomic, weak) IBOutlet UILabel *pageCountLabel;
@property (nonatomic, weak) IBOutlet UISlider *pageSlider;
@property (nonatomic, weak) IBOutlet UILabel *bookTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *chapterTitleLabel;

@property (nonatomic, weak) IBOutlet UIView *topLineDivider;

@property (nonatomic, strong) IBOutlet RESelectionTool *selectionView;

@property (nonatomic, assign) BOOL toolbarModeEnabled;

@property (nonatomic, assign) NSTimeInterval lastTimeWhenPageProgressWasUpdated;

@property (nonatomic) UIPageViewController *pageController;

@property (nonatomic) REDocumentReader *reader;

@property (nonatomic, assign) NSUInteger potentialIndex;


@end

@implementation REMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeReader];
    
    [READER loadDocumentWithPath:[self documentInfo][@"file"]
                 completionBlock:^(REDocument *document)
    {
        [[self reader] setDocument:document];
        [[self reader] needsUpdatePagesWithFrame:self.readerViewPlaceHolder.bounds];
        [self initializePageViewController];
        
        [[self selectionView] setAttributedString:[document attributedString]];
        
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
    [[self pageSlider] setMaximumValue:self.reader.framesCount];
    [[self pageSlider] setValue:_potentialIndex animated:TRUE];
}

- (void) updateProgressLabels
{
    NSTimeInterval time = CACurrentMediaTime();
    
    [[self pageCountLabel] setText:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.reader.currentFrame + 1, (unsigned long)self.reader.framesCount]];
    [[self bookTitleLabel] setText:[self documentInfo][@"title"]];

    if (time - _lastTimeWhenPageProgressWasUpdated > 0.2)
    {
        [[self chapterTitleLabel] setText:self.reader.currentChapterTitle];
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

- (void) buildSelectionViewLinesWithPageView:(REPageView *)pageView
{
    [[self selectionView] setRuns:[pageView runs]];
    [[self selectionView] buildLines];
}

- (void) clearSelectionView
{
    [[self selectionView] clear];
}

- (void) initializeReader
{
    REDocumentReader *reader = [[REDocumentReader alloc] init];
    [reader setDelegate:self];
    [self setReader:reader];
}

- (void) initializePageViewController
{
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    [self.pageController setDelegate:self];
    [self.pageController setDataSource:self];
    
    [self.pageController.view setFrame:self.view.bounds];
    [self.pageController.view setBackgroundColor:[UIColor redColor]];
    
    [[self pageControllerViewPlaceHolder] addSubview:self.pageController.view];
    
    REPageViewController *viewController = [self pageViewControllerForPage:self.reader.currentFrame];
    
    [self.pageController setViewControllers:@[viewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self.pageController didMoveToParentViewController:self];
}

#pragma mark - UIPageViewControllerDataSource  -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (self.reader.currentFrame - 1 >= 0) 
    {
        _potentialIndex = self.reader.currentFrame - 1;
        
        REPageViewController *prevViewController = [self pageViewControllerForPage:_potentialIndex];
                
        return prevViewController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (self.reader.currentFrame + 1 < self.reader.framesCount) 
    {
        _potentialIndex = self.reader.currentFrame + 1;
        
        REPageViewController *nextViewController = [self pageViewControllerForPage:_potentialIndex];

        return nextViewController;
    }
    
    return nil;
}

- (REPageViewController *) pageViewControllerForPage:(NSUInteger)page
{
    REPageViewController *viewController = [[REPageViewController alloc] initWithViewFrame:[self readerViewPlaceHolder].frame];
    [[viewController view] setFrame:self.pageController.view.bounds];
    [viewController setCTFrame:[self.reader cTFrameAtIndex:page] 
                   attachments:[self.reader attachments]];
    
    return viewController;
}


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [self clearSelectionView];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) 
    {
        [[self reader] setCurrentFrame:_potentialIndex];
        
        [self updateProgressLabels];
        [self updatePageSlider];
    }
    
    REPageViewController *viewController = (REPageViewController *)[[pageViewController viewControllers] lastObject];
    
    [self performSelector:@selector(buildSelectionViewLinesWithPageView:) 
               withObject:[viewController pageView] 
               afterDelay:0.5];
    
}

#pragma mark - Actions -

- (IBAction) sliderValueDidChanged:(UISlider *)sender
{
    NSUInteger frameIndex = (int)sender.value;
    
    [[self pageCountLabel] setText:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)frameIndex, (unsigned long)self.reader.framesCount]];
}

- (IBAction) sliderDidTouchedDown:(UISlider *)sender
{
    [self clearSelectionView];
}

- (IBAction) sliderDidToucheUp:(UISlider *)sender
{
    _potentialIndex = (int)sender.value - 1;
    [[self reader] setCurrentFrame:_potentialIndex];
    
    REPageViewController *viewController = [self pageViewControllerForPage:_potentialIndex];
  
    [self performSelector:@selector(buildSelectionViewLinesWithPageView:) 
               withObject:[viewController pageView] 
               afterDelay:0.5];
    
    [self.pageController setViewControllers:@[viewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:TRUE
                                 completion:nil];
}

- (IBAction) longPress:(UILongPressGestureRecognizer *)gesture
{
    [[self selectionView] longPress:gesture];
}

- (IBAction) doubleLeftSwipe:(UIGestureRecognizer *)sender
{
    [[self navigationController] popViewControllerAnimated:TRUE];
}

- (IBAction) tap:(UIGestureRecognizer *)sender
{
    _toolbarModeEnabled = !_toolbarModeEnabled;
    [self updateElemnentsVisibility];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // TO DO :
}

#pragma mark - REMainReaderViewDelegate - 
  // TO DO 
- (void) reader:(REDocumentReader *) readerView pageWillChanged:(NSUInteger)pageIndex
{
}

- (void) reader:(REDocumentReader *) readerView pageDidChanged:(NSUInteger)pageIndex
{
}

@end
