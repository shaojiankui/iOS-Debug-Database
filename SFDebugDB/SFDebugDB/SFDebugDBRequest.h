//
//  SFDebugDBRequest.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDebugDBRequest : NSObject
@property (nonatomic,copy) NSMutableDictionary <NSString*,NSString*> *headers;
@property (nonatomic,copy) NSString *headerString;
@property (nonatomic,copy) NSString *method;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *HTTPVersion;
- (instancetype)initWithData:(NSData*)data;
@end
