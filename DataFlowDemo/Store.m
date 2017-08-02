//
//  Store.m
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/7/31.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "Store.h"
#import <objc/message.h>

@interface Store()

@property (nonatomic, strong) NSMutableArray *subscribers;
@property (nonatomic, copy) Reducer reducer;
@property (nonatomic, strong) id<StateType> state;

@end

@implementation Store

- (instancetype)initWithReducer:(Reducer )reducer initialState:(id<StateType>)state {
    NSAssert(reducer != nil, @"reducer must not be nil");
    NSAssert(state != nil, @"initialState must not be nil");
    if (self = [super init]) {
        self.state = state;
        self.reducer = reducer;
    }
    return self;
}

- (void)subscribeNext:(SubscribeBlock)subscriber {
    [self.subscribers addObject:[subscriber copy]];
}

- (void)unsubscribe {
    [self.subscribers removeAllObjects];
}
- (void)dispatch:(id<ActionType>)action {
    id<StateType> previousState = _state;
    id<StateType> nextState = self.reducer(previousState,action);
    if (nextState.isValidState) {
     self.state = nextState;
        if (self.subscribers.count > 0) {
            __weak __typeof(self)weakSelf = self;
            [self.subscribers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @synchronized (weakSelf) {
                    SubscribeBlock block = (SubscribeBlock)obj;
                    block(previousState,nextState);
                }
            }];
        }
    }
}
- (NSMutableArray *)subscribers {
    if (!_subscribers) {
        _subscribers = [NSMutableArray array];
    }
    return _subscribers;
}

@end

