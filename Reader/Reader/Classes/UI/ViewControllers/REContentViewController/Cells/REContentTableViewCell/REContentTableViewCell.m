//
//  REContentTableViewCell.m
//  Reader
//
//  Created by Vladimir Gogunsky on 5/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REContentTableViewCell.h"

@interface REContentTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;

@end

@implementation REContentTableViewCell

- (void) setupWithInfo:(NSDictionary *)info
{
    self.titleLabel.text = info[@"title"];
    self.descriptionLabel.text = info[@"author"];
}

@end
