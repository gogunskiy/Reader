//
//  RESelectionTool.h
//  Reader
//
//  Created by gogunsky on 4/13/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RESelectionToolDelegate;

typedef NS_ENUM(NSUInteger, RESelectionToolActionType) 
{
    RESelectionToolActionCopy,
    RESelectionToolActionShare,
    RESelectionToolActionGoogle,
    RESelectionToolActionTranslate
};

@interface RESelectionTool : UIView

@property (nonatomic, weak) IBOutlet NSObject <RESelectionToolDelegate> *delegate;

@property (nonatomic) NSAttributedString *attributedString;
@property (nonatomic) NSArray *runs;

- (BOOL) longPress:(UILongPressGestureRecognizer *)gesture;

- (void) buildLines;
- (BOOL) reset;

- (NSString *) text;

@end


@protocol RESelectionToolDelegate

-(void) selectionTool:(RESelectionTool *) selectionTool clickedItemWithType:(RESelectionToolActionType)type selectedText:(NSString *)selectedtText;

@end