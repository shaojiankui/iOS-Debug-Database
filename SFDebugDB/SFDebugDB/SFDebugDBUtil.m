//
//  SFDebugDBUtil.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDBUtil.h"

@implementation SFDebugDBUtil

@end
@implementation NSDictionary (SFDebugDBJSONString)
-(NSString *)sf_dic_JSONString{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"fail to get JSON from dictionary: %@, error: %@", self, error);
#endif
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end



@implementation NSArray (SFDebugDBJSONString)
-(NSString *)sf_array_JSONString{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"fail to get JSON from dictionary: %@, error: %@", self, error);
#endif
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end


@implementation NSString (sf_urlParam)
static NSString *const kQuerySeparator      = @"&";
static NSString *const kQueryDivider        = @"=";
static NSString *const kQueryBegin          = @"?";
static NSString *const kFragmentBegin       = @"#";
- (NSDictionary *)sf_url_parameters
{
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [self componentsSeparatedByString:kQuerySeparator]) {
        NSArray *components = [query componentsSeparatedByString:kQueryDivider];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = nil;
        if (components.count == 1) {
            // key with no value
            value = [NSNull null];
        }
        if (components.count == 2) {
            value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // cover case where there is a separator, but no actual value
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2) {
            // invalid - ignore this pair. is this best, though?
            continue;
        }
        mute[key] = value ?: [NSNull null];
    }
    return mute.count ? mute.copy : nil;

}

- (NSString *)sf_url_valueForParameter:(NSString *)parameterKey
{
    if ([[[self sf_url_parameters] objectForKey:parameterKey] isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [[self sf_url_parameters] objectForKey:parameterKey];
}
- (NSString *)sf_query_valueForParameter:(NSString *)parameterKey
{
    NSString *string = [[self sf_url_parameters] objectForKey:parameterKey];
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    NSRange range =  [self rangeOfString:@"?"];
    if(range.location != NSNotFound && (range.location+1<=[self length])){
        string = [([[self substringFromIndex:range.location+1] sf_url_valueForParameter:parameterKey]?:@"") stringByRemovingPercentEncoding];
    }
    
    return string;
}

@end


@implementation NSString (sf_dictionaryValue)
-(id)sf_JSONObejctValue{
    NSError *errorJson;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&errorJson];
    if (errorJson != nil) {
#ifdef DEBUG
        NSLog(@"fail to get dictioanry from JSON: %@, error: %@", self, errorJson);
#endif
    }
    return jsonDict;
}
@end

