//
//  SFDebugDBRespone.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDBRespone.h"

@implementation SFDebugDBRespone
- (instancetype)init
{
    self = [super init];
    if (self) {
        _statusCode = 200;
    }
    return self;
}
- (instancetype)initWithHTML:(NSString*)html{
    self = [super init];
    if (self) {
        _html = html;
        _statusCode = 200;
    }
    return self;
}
- (instancetype)initWithHTMLData:(NSData*)htmlData{
    self = [super init];
    if (self) {
       _htmlData = htmlData;
        _statusCode = 200;
    }
    return self;
}
- (instancetype)initWithFileName:(NSString*)fileName{
    self = [super init];
    if (self) {
        _htmlData =  [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName]];
        _contentType = [[self class] detectMimeType:fileName];
        _statusCode = 200;
    }
    return self;
}
- (instancetype)initWithFile:(NSString*)filePath{
    self = [super init];
    if (self) {
        _htmlData =  [NSData dataWithContentsOfFile:filePath];
        _contentType = [[self class] detectMimeType:filePath];
        _statusCode = 200;
    }
    return self;
}
//static inline NSString* _EscapeHTMLString(NSString* string) {
//    return [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
//}
//- (instancetype)initWithStatusCode:(NSInteger)statusCode underlyingError:(NSError*)underlyingError messageFormat:(NSString*)format arguments:(va_list)arguments {
//    NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
//    NSString* title = [NSString stringWithFormat:@"HTTP Error %i", (int)statusCode];
//    NSString* error = underlyingError ? [NSString stringWithFormat:@"[%@] %@ (%li)", underlyingError.domain, _EscapeHTMLString(underlyingError.localizedDescription), (long)underlyingError.code] : @"";
//    NSString* html = [NSString stringWithFormat:@"<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>%@</title></head><body><h1>%@: %@</h1><h3>%@</h3></body></html>",
//                      title, title, _EscapeHTMLString(message), error];
//    if ((self = [self initWithHTML:html])) {
//        self.statusCode = statusCode;
//    }
//    return self;
//}
-(NSData *)data{
 
//     _htmlData?:[_html dataUsingEncoding:NSUTF8StringEncoding]
    NSString *response;
    if (self.htmlData) {
        self.html = [[NSString alloc]initWithData:_htmlData encoding:NSUTF8StringEncoding];
        self.contentLength = self.htmlData.length;
    }else{
        NSData *data = [_html dataUsingEncoding:NSUTF8StringEncoding];
        self.contentLength = data.length;
    }
    if ([self.contentType isEqualToString:@"application/octet-stream"] || self.contentDisposition) {
        self.contentType = @"application/octet-stream";
//        self.contentDisposition = []
        self.html = [[NSString alloc]initWithData:_htmlData encoding:NSASCIIStringEncoding];

        response = [NSString stringWithFormat:@"HTTP/1.1 %zd OK\nContent-Type: %@; charset=UTF-8\n%@%@\n\n",_statusCode,self.contentType?:@"text/html",self.html?:@"",self.contentDisposition];

    }else{
        response = [NSString stringWithFormat:@"HTTP/1.1 %zd OK\nContent-Type: %@; charset=UTF-8\n\n%@",_statusCode,self.contentType?:@"text/html",self.html?:@""];
    }
    return [response dataUsingEncoding:NSUTF8StringEncoding];
}
+ (NSString*)detectMimeType:(NSString *)fileName{
    if (fileName.length==0) {
        return nil;
    } else if ([fileName hasSuffix:@".html"]) {
        return @"text/html";
    } else if ([fileName hasSuffix:@".js"]) {
        return @"application/javascript";
    } else if ([fileName hasSuffix:@".css"]) {
        return @"text/css";
    } else {
        return @"application/octet-stream";
    }
}
@end
