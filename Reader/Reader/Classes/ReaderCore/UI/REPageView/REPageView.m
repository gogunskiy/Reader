//
//  REPageView.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/4/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REPageView.h"

@interface REPageView()

@property (nonatomic, assign) CTFrameRef frameRef;

@property (nonatomic) NSArray *attachments;

@end

@implementation REPageView


- (void) setCTFrame:(CTFrameRef)frame attachments:(NSArray *)attachments
{
    _frameRef = frame;
    _attachments = attachments;
    
    [self setNeedsDisplay];
}

- (NSArray *) runs
{
    NSMutableArray *runs = [NSMutableArray new];
    
    NSArray *lines = (NSArray *)CTFrameGetLines(_frameRef);
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), origins);
    
    NSInteger index = 0;
    
    
    for (id lineObj in lines)
    {
        CTLineRef line = (__bridge CTLineRef)lineObj;
        CFRange lineRange = CTLineGetStringRange(line);
        
        CGRect lineBounds;
        CGFloat ascent;
        CGFloat descent;
        lineBounds.size.width = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        lineBounds.size.height = ascent + descent;
        
        lineBounds.origin.x = origins[index].x;
        lineBounds.origin.y = origins[index].y;
        lineBounds.origin.y -= descent;
        lineBounds.origin.y = self.frame.size.height - CGRectGetMaxY(lineBounds);
        
        for (long i = lineRange.location; i < (lineRange.location + lineRange.length) - 1; i++)
        {
            CGFloat startOffset = CTLineGetOffsetForStringIndex(line, i, NULL);
            CGFloat endOffset = CTLineGetOffsetForStringIndex(line, i + 1, NULL);
            
            CGRect characterBounds = lineBounds;
            
            characterBounds.origin.x += startOffset;
            characterBounds.size.width = endOffset - startOffset;
            
            [runs addObject:@{@"frame" : [NSValue valueWithCGRect:characterBounds], @"range" : [NSValue valueWithRange:NSMakeRange(i, 1)]}];
        }
        
        index ++;
    }
    
    return runs;
}

- (void) insertAttachments:(NSArray *)array
{
    for (UIView *view in [self subviews])
    {
        [view removeFromSuperview];
    }
    
    if ([_attachments count])
    {
        NSArray *lines = (NSArray *)CTFrameGetLines(_frameRef);
        CGPoint origins[[lines count]];
        CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), origins);
        
        NSInteger index = 0;
        
        for (id lineObj in lines)
        {
            CTLineRef line = (__bridge CTLineRef)lineObj;
            
            for (id runObj in (NSArray *)CTLineGetGlyphRuns(line))
            {
                CTRunRef run = (__bridge CTRunRef)runObj;
                CFRange runRange = CTRunGetStringRange(run);
                
                for (NSDictionary *attachment in  array)
                {
                    NSInteger location = [attachment[@"location"] integerValue];
                
                    if ( runRange.location <= location && runRange.location+runRange.length > location)
                    {
                        CGRect runBounds;
                        CGFloat ascent;
                        CGFloat descent;
                        runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                        runBounds.size.height = ascent + descent;
                        
                        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9

                        runBounds.origin.y = origins[index].y;
                        runBounds.origin.y -= descent;
                        runBounds.origin.y = self.frame.size.height - CGRectGetMaxY(runBounds);
                        
                        
                        CTTextAlignment aligment = (CTTextAlignment)[attachment[@"aligment"] integerValue];
                        
                        switch (aligment)
                        {
                            case kCTTextAlignmentCenter:
                            {
                                runBounds.origin.x = self.frame.size.width / 2 - runBounds.size.width / 2;
                                break;
                            }                               
                            default:
                            {
                                runBounds.origin.x = origins[index].x + xOffset;
                                break;
                            }
                        }
                        
                        if ([attachment[@"attachmentType"] isEqualToString:@"image"]) 
                        {
                            UIImageView *view = [[UIImageView alloc] initWithFrame:runBounds];
                            UIImage *image = [[UIImage alloc] initWithContentsOfFile:attachment[@"fileName"]];
                            [view setContentMode:UIViewContentModeScaleAspectFit];
                            [view setImage:image];
                            [view setBackgroundColor:[UIColor clearColor]];
                            [self addSubview:view];
                        }
                        else if ([attachment[@"attachmentType"] isEqualToString:@"tableRow"]) 
                        {
                            UIImageView *view = [[UIImageView alloc] initWithFrame:runBounds];
                            if ([attachment[@"userData"] isEqualToString:@"th"]) 
                            {
                                [view setBackgroundColor:[UIColor lightGrayColor]];
                            }
                            else
                            {
                                [view setBackgroundColor:[UIColor whiteColor]];
                            }
                            
                            [[view layer] setBorderWidth:2.0];
                            [[view layer] setBorderColor:[UIColor darkGrayColor].CGColor];
                            
                            [self addSubview:view];
                        }
                    }
                }
            }
            
            index ++;
        }
    }
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(_frameRef, context);
    
    [self insertAttachments:_attachments];
}

- (void)dealloc
{
    if (_frameRef) 
    {
        CFRelease(_frameRef);
    }
}

- (UIImage *) snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
