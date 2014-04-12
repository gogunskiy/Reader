//
//  UIImage+Sizes.m
//  Reader
//
//  Created by gogunsky on 4/12/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "UIImage+Sizes.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (Sizes)


+ (CGSize) sizeOfImageAtURL:(NSURL *)imageURL
{
    CGSize imageSize = CGSizeZero;
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    if (source)
    {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCGImageSourceShouldCache];
        CFDictionaryRef properties = (__bridge CFDictionaryRef)((__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, (__bridge CFDictionaryRef)options));
        if (properties)
        {
            NSNumber *width = [(__bridge NSDictionary *)properties objectForKey:(NSString *)kCGImagePropertyPixelWidth];
            NSNumber *height = [(__bridge NSDictionary *)properties objectForKey:(NSString *)kCGImagePropertyPixelHeight];
            if ((width != nil) && (height != nil))
                imageSize = CGSizeMake(width.floatValue, height.floatValue);
            CFRelease(properties);
        }
        CFRelease(source);
    }
    return imageSize;
}

@end
