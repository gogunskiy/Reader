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

@end

@implementation REMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"section1.xhtml"];
    [READER loadFile:filePath completionBlock:^(REDocument *document)
    {
        [[self readerView] setDocument:document];
        [[self readerView] needsUpdatePages];
        [self updateUI];
    } 
                  errorBlock:^(NSError *error) 
    {
        
    }];
    
}

- (void) updateUI
{
    [[self pageCountLabel] setText:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.readerView.currentPage, (unsigned long)self.readerView.pageCount]];
}

#pragma mark - Actions -

- (IBAction) leftSwipe:(UIGestureRecognizer *)sender
{
    [[self readerView] showNextPage];
    
    [self updateUI];
}

- (IBAction) rightSwipe:(UIGestureRecognizer *)sender
{
    [[self readerView] showPreviousPage];
    
    [self updateUI];
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
        // show toolBar
    }
    else
    {
        [self leftSwipe:nil];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

@end
