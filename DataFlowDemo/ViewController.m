//
//  ViewController.m
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/8/1.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "ViewController.h"
#import "Store.h"
#import "FetchData.h"
#import "DetailViewController.h"
#import "History+CoreDataClass.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kCellH 50
@interface State :NSObject<StateType,NSCopying>

@property (nonatomic, copy) NSArray *cities;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSArray *histories;

@end

@implementation State

- (id)copyWithZone:(NSZone *)zone {
    State *copy = [[[self class] allocWithZone:zone] init];
    copy.cities = self.cities;
    copy.text = self.text;
    copy.histories = self.histories;
    return copy;
}

@end

typedef NS_ENUM(NSUInteger, Action_Type) {
    
    UpdateText_Action,
    AddCities_Action,
    AddHistories_Action,
    
    //异步command
    FetchCities_Action,
    FetchHistories_Action,
    FetchAssociate_Action,
    ClearHistory_Action,
};
@interface Action :NSObject<ActionType>

@property (nonatomic, assign) Action_Type actionType;
@property (nonatomic, strong) id associateValues;

+ (instancetype)actionWithActionType:(Action_Type) type values:(id)associateValues;

@end

@implementation Action

+ (instancetype)actionWithActionType:(Action_Type)type values:(id)associateValues {
    Action *action = [[Action alloc] init];
    action.actionType = type;
    action.associateValues = associateValues;
    return action;
}
@end


typedef NS_ENUM(NSUInteger, SectionNum) {
    HistorySection,
    CitiesSection,
    AllSectionNum,
};



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) Store *store;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"clearHistory" style:UIBarButtonItemStylePlain target:self action:@selector(clearHistory)];
    [self.textField addTarget:self action:@selector(changed:) forControlEvents:UIControlEventEditingChanged];
    
    
    State *initialState = [[State alloc] init];
    _store = [[Store alloc] initWithReducer:self.reducer initialState:initialState];
    __weak __typeof(self)weakSelf = self;
    
    [_store subscribeNext:^(State *new) {
        [weakSelf stateDidChangeWithNew:new];
    }];
    
    Action *fetchCitiesAction = [Action actionWithActionType:FetchCities_Action values:nil];
    [_store dispatch:fetchCitiesAction];//3
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    Action *fetchHistoryAction = [Action actionWithActionType:FetchHistories_Action values:nil];
    [_store dispatch:fetchHistoryAction];//1
}

- (void)clearHistory {
    Action *clearAll = [Action actionWithActionType:ClearHistory_Action values:nil];
    [self.store dispatch:clearAll];
}

- (void)stateDidChangeWithNew:(State *)new{
    
    [self.tableView reloadData];
    //update title
    if (new.text == nil || new.text.length == 0) {
        self.title = @"省";
    } else {
        self.title = new.text;
    }
}

- (Reducer )reducer {
    __weak __typeof(self)weakSelf = self;
    Reducer reducer = ^(id<StateType> state, id<ActionType>action){
        State *previousState = (State *)state;
        State *currentState = previousState;
        switch (action.actionType) {
            case UpdateText_Action:
            {
                id associateValue  = action.associateValues;
                currentState.text = associateValue;
                break;
            }
            case AddCities_Action:
            {
                id associateValue  = action.associateValues;
                currentState.cities = associateValue;
                break;
            }
            case AddHistories_Action:
            {
                id associateValue  = action.associateValues;
                currentState.histories = associateValue;
                break;
            }

            case FetchCities_Action: {
                [FetchData fetchCities:^(NSArray *data, NSError *error) {
                    Action *action = [Action new];
                    action.actionType = AddCities_Action;
                    action.associateValues = data;
                    [weakSelf.store dispatch:action];//4
                }];
                break;
            }
            case FetchAssociate_Action: {
                id associateValue  = action.associateValues;
                [FetchData fetchAssociate:associateValue handler:^(NSArray *data, NSError *error) {
                    Action *action = [Action new];
                    action.actionType = AddCities_Action;
                    action.associateValues = data;
                    [weakSelf.store dispatch:action];
                }];
                break;
            }
            case FetchHistories_Action: {
                [FetchData fetchHistories:^(NSArray *data, NSError *error) {
                    Action *action = [Action new];
                    action.actionType = AddHistories_Action;
                    action.associateValues = data;
                    [weakSelf.store dispatch:action];//2
                }];
                break;
            }
            case ClearHistory_Action: {
                [History clearAllCompletion:^{
                    Action *action = [Action new];
                    action.actionType = AddHistories_Action;
                    action.associateValues = nil;
                    [weakSelf.store dispatch:action];//2
                }];
            
                break;
            }
                
            default:
                break;
        }
        return currentState;
    };
    
    return reducer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return AllSectionNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HistorySection){
        State *currentState = (State *)self.store.state;
        return currentState.histories.count;
    } else {
        State *currentState = (State *)self.store.state;
        return currentState.cities.count;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.section == HistorySection) {
        cell.textLabel.text = [self titleInHistoryAtIndexPath:indexPath];
    } else {
        cell.textLabel.text = [self titleInCitiesAtIndexPath:indexPath];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    label.frame = CGRectMake(0, 0, kScreenW, 20);
    
    NSString *title;
    if (section == CitiesSection) {
        title = @"省";
    } else if (section == HistorySection) {
        title = @"历史";
    }
    
    label.text = title;
    return label;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailViewController *detail = [DetailViewController new];
    
  NSString *title = [self titleInCitiesAtIndexPath:indexPath];
    
    detail.title = title;
    [self.navigationController pushViewController:detail animated:YES];
    
    //save history
    [History updateWithName:title];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSString *)titleInCitiesAtIndexPath:(NSIndexPath *)indexPath {
    State *currentState = (State *)self.store.state;
    NSDictionary *currentCity = currentState.cities[indexPath.row];
    return currentCity[@"provinceName"];
}

- (NSString *)titleInHistoryAtIndexPath:(NSIndexPath *)indexPath {
    State *currentState = (State *)self.store.state;
    History *hisotry = currentState.histories[indexPath.row];
    return hisotry.name;
}

- (void)changed:(UITextField *)textFiled {
    //关联updateText
    NSLog(@"%@",textFiled.text);
    Action *action2 = [Action actionWithActionType:UpdateText_Action values:textFiled.text];
    [self.store dispatch:action2];

    if (textFiled.text.length > 0) {
        //关联action
        Action *action1 = [Action actionWithActionType:FetchAssociate_Action values:textFiled.text];
        [self.store dispatch:action1];
    } else {
        Action *action = [Action actionWithActionType:FetchCities_Action values:textFiled.text];
        [self.store dispatch:action];
    }
    
}



@end
