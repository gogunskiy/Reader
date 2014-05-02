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
#import "REPathManager.h"
#import "REContentTableViewCell.h"



@interface REContentViewController ()

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *items;
@property (nonatomic) enum RESortingType sorting;


@end

@implementation REContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sorting = RESortingByName;
    [self setItems:[self sortItems:[READER documents]]];
    [[self tableView] reloadData];
}

- (NSArray *) sortItems:(NSArray *)items
{
    NSString *sortKey= @"title";
    
    switch (_sorting) 
    {
        case RESortingByAuthor:
        {
            sortKey = @"author";
            
            break;   
        }
            
        default:
        {
            sortKey= @"title";
            
            break;
        }
    }
    
    return [items sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) 
            {
                if ([obj1[sortKey] lowercaseString] > [obj2[sortKey] lowercaseString]) 
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedDescending;
                }
            }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    REContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([REContentTableViewCell class]) owner:self options:nil][0];
        [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    }
    
    NSDictionary * item = _items[indexPath.row];
 
    [cell setupWithInfo:item];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    REMainViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:NSStringFromClass([REMainViewController class])];
    [viewController setDocumentInfo:_items[indexPath.row]];
    
    [[self navigationController] pushViewController:viewController animated:TRUE];
}


@end
