//
//  Store.h
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/7/31.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ActionType <NSObject>
@property (nonatomic, assign) NSUInteger actionType;
@property (nonatomic, strong) id associateValues;
@end
@protocol StateType <NSObject>

@end
@protocol CommandType <NSObject>

@end

typedef id<StateType> (^Reducer)(id<StateType> state, id<ActionType>action);
typedef void (^SubscribeBlock)(id<StateType> new);

@interface Store : NSObject

@property (nonatomic, strong,readonly) id<StateType> state;

- (instancetype)initWithReducer:(Reducer )reducer
                   initialState:(id<StateType>)state;

- (void)subscribeNext:(SubscribeBlock)subscriber;
- (void)unsubscribe;
- (void)dispatch:(id<ActionType>)action;

@end

