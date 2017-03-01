//
//  ResponseModel.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDBModel.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
@implementation SFDebugDBModel
-(NSDictionary *)propertyDictionary
{
    //创建可变字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for(int i=0;i<outCount;i++){
        objc_property_t prop = props[i];
        NSString *propName = [[NSString alloc]initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        id propValue = [self valueForKey:propName];
        //        if(propValue){
        [dict setObject:propValue?:[NSNull null] forKey:propName];
        //        }
    }
    free(props);
    return dict;
}
@end
