//
//  SFDebugDBRespone.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDebugDBRespone : NSObject
@property (nonatomic,copy)   NSString *html;
@property (nonatomic,strong) NSData *htmlData;
@property (nonatomic,assign) NSInteger statusCode;
@property (nonatomic,strong) NSData *data;
@property (nonatomic,copy)   NSString *contentType;

@property (nonatomic,assign) NSUInteger contentLength;
@property (nonatomic,copy)   NSString *contentDisposition;

- (instancetype)initWithHTML:(NSString*)html;
- (instancetype)initWithHTMLData:(NSData*)htmlData;
- (instancetype)initWithFile:(NSString*)filePath;
- (instancetype)initWithFileName:(NSString*)fileName;
@end
