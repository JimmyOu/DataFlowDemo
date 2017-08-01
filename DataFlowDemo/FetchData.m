//
//  FetchData.m
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/7/31.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "FetchData.h"
#import "History+CoreDataClass.h"
static NSTimeInterval _lastInvoke = 0;
@implementation FetchData

+ (void)fetchHistories:(void(^)(NSArray *data, NSError *error))handler {
    
   NSArray *array = [History fetchAllHistory];
    if (handler) {
        handler(array,nil);
    }
  
}

+ (void)fetchCities:(void(^)(NSArray *data, NSError *error))handler {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (handler) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"province.json" ofType:nil];
            NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
            
            NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            handler(dic[@"ret"][@"result"],nil);
        }
    });

}

+ (void)fetchAssociate:(NSString *)keyword handler:(void(^)(NSArray *data, NSError *error))handler {
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval last = _lastInvoke;
    
    if (current - last >= 0.4) { //两次请求间隔相差0.5以上。
        _lastInvoke = current;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (handler) {
                NSString *path = [[NSBundle mainBundle] pathForResource:@"province.json" ofType:nil];
                NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
                
                NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                
                NSArray *array = dic[@"ret"][@"result"];
    
                
                NSArray *matchArr = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.provinceName CONTAINS[cd] %@", keyword]];
                handler(matchArr,nil);
            }
        });
    }

    
}

@end
