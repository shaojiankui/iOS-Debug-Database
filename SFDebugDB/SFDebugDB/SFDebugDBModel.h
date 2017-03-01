//
//  ResponseModel.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDebugDBModel : NSObject
@property (nonatomic,strong)   NSArray *rows;
@property (nonatomic,strong)   NSArray *columns;
@property (nonatomic,assign)   BOOL isSuccessful;
@property (nonatomic,copy)   NSString *error;
@property (nonatomic,assign)  NSInteger dbVersion;
@end
