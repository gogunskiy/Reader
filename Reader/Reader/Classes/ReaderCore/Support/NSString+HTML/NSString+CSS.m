

#import "NSString+CSS.h"

@implementation NSString (CSS)

#pragma mark CSS

- (NSDictionary *)dictionaryOfCSSStyles
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *cssString = [self copy];
    
    cssString = [cssString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cssString = [cssString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    cssString = [cssString stringByReplacingOccurrencesOfString:@" " withString:@""];
    cssString = [cssString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    cssString = [cssString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSArray *elements = [cssString componentsSeparatedByString:@"}"];
    
    for (NSString *chunk in elements) 
    {
        NSArray *parts = [chunk componentsSeparatedByString:@"{"];
        
        if (parts.count > 1) 
        {
            NSArray *attributes = [parts[1] componentsSeparatedByString:@";"];
            
            NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
            
            for (NSString *attr in attributes) 
            {
                NSArray *parts = [attr componentsSeparatedByString:@":"];
                if (parts.count > 1) 
                {
                    NSString *key = parts[0];
                    NSString *value = parts[1];
                    
                    attrs[key] = value;
                }
                
            }
            dict[parts[0]] = attrs;
        }
    }
    
    return dict;
}

@end
