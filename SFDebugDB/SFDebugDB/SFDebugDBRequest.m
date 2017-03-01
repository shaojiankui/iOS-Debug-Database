//
//  SFDebugDBRequest.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDBRequest.h"

@implementation SFDebugDBRequest
- (instancetype)initWithData:(NSData*)data{
    self = [super init];
    if (self) {
        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        self.headerString = string;
        NSArray *headerArray = [string componentsSeparatedByString:@"\r\n"];
        NSString *info = [headerArray firstObject];
        
        _headers =  [NSMutableDictionary dictionary];
        if (info) {
            NSArray *infoArray = [info componentsSeparatedByString:@" "];
            if ([infoArray count] == 3)
            {
                _method      = infoArray[0];
                _path        = infoArray[1];
                _HTTPVersion = infoArray[2];
            }
            for (int i = 1; i<[headerArray count]; i++) {
                NSString *h = [headerArray objectAtIndex:i];
                NSString *key   = [[h componentsSeparatedByString:@": "] firstObject];
                NSString *value = [[h componentsSeparatedByString:@": "] lastObject];
                _headers[key] = value;
            }
        }
        NSLog(@"DBRequest path:%@",_path);
    }
    return self;
}
@end
