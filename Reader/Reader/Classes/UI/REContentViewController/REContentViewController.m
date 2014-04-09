//
//  REContentViewController.m
//  Reader
//
//  Created by Gogunsky Vladimir on 4/9/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REContentViewController.h"
#import "REReaderController.h"
#import "REMainViewController.h"

@interface REContentViewController ()

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *items;

@end

@implementation REContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setItems:[READER documents]];
    [[self tableView] reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    }
    
    NSDictionary * item = [self items][indexPath.row];
    [[cell textLabel] setText:item[@"title"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushViewControllerWithIdentifier:[REMainViewController class]];
}


@end
