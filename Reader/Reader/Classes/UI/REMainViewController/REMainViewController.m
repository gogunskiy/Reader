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

@end

@implementation REMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    REReaderController *viewController = [[REReaderController alloc] init];
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"chapter-001.xml"];
    [viewController loadFile:filePath completionBlock:^(REDocument *document) 
    {
        [[self readerView] setDocument:document];
        [[self readerView] needsUpdatePages];
    } 
                  errorBlock:^(NSError *error) 
    {
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
