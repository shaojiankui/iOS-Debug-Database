//
//  ResponseModel.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TableInfo;
@class ColumnData;

@interface SFDebugDBModel : NSObject
@property (nonatomic,strong)   NSMutableArray *tableInfos;
@property (nonatomic,assign)   BOOL isSuccessful;
@property (nonatomic,strong)   NSMutableArray *rows;
@property (nonatomic,copy)   NSString *errorMessage;
@property (nonatomic,assign)   BOOL isEditable;
@property (nonatomic,assign)   BOOL isSelectQuery;
-(NSDictionary *)propertyDictionary;

@end



@interface SFDebugDBModelTableInfo : NSObject
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) BOOL isPrimary;
@end


@interface SFDebugDBModelColumnData : NSObject
@property (nonatomic,copy) NSString *dataType;
@property (nonatomic,strong) id value;
@end
