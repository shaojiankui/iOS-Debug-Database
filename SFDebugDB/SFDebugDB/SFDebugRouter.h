//
//  SFDebugRouter.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFDebugDBRequest.h"
#import "SFDebugDBRespone.h"

typedef SFDebugDBRespone* (^SFDebugRouterHandler)(SFDebugDBRequest *request);

@interface SFDebugRouter : NSObject
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *method;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) SFDebugRouterHandler handler;
@end
