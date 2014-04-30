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
#import "REUtils.h"

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
@property (nonatomic, assign) BOOL pageIsAnimating;
@property (nonatomic, assign) BOOL isSelectionEnabled;
@end

@implementation REMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeReader];
    
    [self startLoadingIndicatorWithCurrentValue:0 maxvalue:100];
    
    [READER loadDocumentWithPath:[self documentInfo][@"file"]
                   progressBlock:^(REDocument *document) 
     {
         NSArray *chaptersInfo = document.info[@"chapters"];
         
         [self updateLoadingIndicatorWithCurrentValue:document.chapters.count 
                                             maxvalue:chaptersInfo.count];
     } 
                 completionBlock:^(REDocument *document)
     {
         [self hideLoadingIndicator];
         
         [[self reader] setDocument:document];
         [[self selectionView] setAttributedString:[document attributedString]];
         
         [[self reader] needsUpdatePagesWithFrame:self.readerViewPlaceHolder.bounds 
                                    progressBlock:^(id frame) 
          {
              dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 if (self.reader.framesCount == 1) 
                                 {
                                     [self initializePageViewController];
                                 }
                                 
                                 [self updateUI];
                             });
              
          } 
                                  completionBlock:^
          {
              
          }];
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

- (void) updateSelectionView:(REPageView *)pageView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(buildSelectionViewLinesWithPageView:) 
               withObject:pageView
               afterDelay:0.0];
}

- (void) buildSelectionViewLinesWithPageView:(REPageView *)pageView
{
    [[self selectionView] setRuns:[pageView runs]];
    [[self selectionView] buildLines];
}

- (void) clearSelectionView
{
    [[self selectionView] reset];
}

- (void) initializeReader
{
    REDocumentReader *reader = [[REDocumentReader alloc] init];
    [reader setDelegate:self];
    [self setReader:reader];
}

- (void) initializePageViewController
{
    if (self.pageController == nil) 
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
}

- (void) showSocialActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a sharing option" 
                                                             delegate:self 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Facebook", @"Twitter", @"SMS", @"Email", nil];
    
    [actionSheet showInView:[self view]];
}

#pragma mark - UIPageViewControllerDataSource  -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{    
    if (self.reader.currentFrame - 1 >= 0 && !_pageIsAnimating)
    {
        _potentialIndex = self.reader.currentFrame - 1;
        
        REPageViewController *prevViewController = [self pageViewControllerForPage:_potentialIndex];
                
        return prevViewController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{    
    if (self.reader.currentFrame + 1 < self.reader.framesCount && !_pageIsAnimating) 
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
    [self setPageIsAnimating:TRUE];
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
    
    [self updateSelectionView:[viewController pageView]];
    
    [self setPageIsAnimating:FALSE];
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
    UIPageViewControllerNavigationDirection direction = _potentialIndex > sender.value + 1 ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    
    _potentialIndex = (int)sender.value + 1;
    [[self reader] setCurrentFrame:_potentialIndex];
    
    REPageViewController *viewController = [self pageViewControllerForPage:_potentialIndex];
    
    [self updateSelectionView:[viewController pageView]];
    
    [self.pageController setViewControllers:@[viewController]
                                  direction:direction
                                   animated:TRUE
                                 completion:nil];
}

- (IBAction) longPress:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _isSelectionEnabled = [[self selectionView] longPress:gesture];
            
            break;
        }
            
            default:
        {
            break;
        }
    }
}

- (IBAction) doubleLeftSwipe:(UIGestureRecognizer *)sender
{
    [[self navigationController] popViewControllerAnimated:TRUE];
}

- (IBAction) tap:(UIGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:[self view]];
    CGRect frame  = [[self view] frame];

    if (point.x > frame.size.width * 0.25 && point.x < frame.size.width * 0.75)
    {
        _toolbarModeEnabled = !_toolbarModeEnabled;
        [self updateElemnentsVisibility];
        _isSelectionEnabled = [[self selectionView] reset];
    }
}

- (IBAction) upSwipe:(UIGestureRecognizer *)sender
{
    [UTILS changeBrightness:0.1];
}

- (IBAction) downSwipe:(UIGestureRecognizer *)sender
{
    [UTILS changeBrightness:-0.1];
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

#pragma mark - RESelectionToolDelegate -

-(void) selectionTool:(RESelectionTool *) selectionTool clickedItemWithType:(RESelectionToolActionType)type selectedText:(NSString *)selectedText
{
    switch (type) 
    {
        case RESelectionToolActionCopy:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:selectedText];
            
            break;
        }
        case RESelectionToolActionShare:
        {
            [self showSocialActionSheet];
            break;
        }
        case RESelectionToolActionGoogle:
        {
            [UTILS openGoogleWithText:[_selectionView text]];
            
            break;
        }
        case RESelectionToolActionTranslate:
        {
            [UTILS openTranslaterWithText:[_selectionView text]];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - UISctionSheetDelegate -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) 
    {
        case 0:
        {
            [UTILS shareFacebookWithText:[_selectionView text] parentViewController:self];
            break;
        }   
        case 1:
        {
            [UTILS shareTwitterWithText:[_selectionView text] parentViewController:self];
            break;
        }   
        case 2:
        {
            [UTILS shareSMSWithText:[_selectionView text] parentViewController:self];
            break;
        }   
        case 3:
        {
            [UTILS shareEmailWithText:[_selectionView text] parentViewController:self];
            break;
        }   
        default:
            break;
    }
}

@end
