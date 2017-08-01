//
//  FetchData.h
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/7/31.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchData : NSObject

+ (void)fetchHistories:(void(^)(NSArray *data, NSError *error))handler;

+ (void)fetchCities:(void(^)(NSArray *data, NSError *error))handler;

+ (void)fetchAssociate:(NSString *)keyword handler:(void(^)(NSArray *data, NSError *error))handler;



@end
