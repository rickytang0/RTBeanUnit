//
//  RTViewController.m
//  RTBeanUnitDemo
//
//  Created by 唐 嘉宾 on 13-5-8.
//  Copyright (c) 2013年 唐 嘉宾. All rights reserved.
//

#import "RTViewController.h"
#import "RTBean.h"
#import "RTBeanUnit.h"

@interface RTViewController ()

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    RTBean *bean = [[RTBean alloc] init];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:120],@"intNum",[NSNumber numberWithFloat:10.04f],@"floatNum",@"2013-4-3 12:00:00",@"date",@"fhasdj",@"string", nil];
    
    RTBeanUnit *beanUnit = [[RTBeanUnit alloc] init];
    [beanUnit setBeanWith:bean andDictionary:dic];
    NSLog(@"valueint %d",bean.intNum);
    NSLog(@"fvalue %f",bean.floatNum);
    NSLog(@"dvalue %@",bean.date);
    
    NSLog(@"bean dic : %@",[beanUnit convertToDictionaryFromBean:bean]);
    
    
    NSString *filePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[NSBundle mainBundle].resourcePath,@"tableArea.json", nil]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if ([obj isKindOfClass:[NSArray class]]) {
            [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                RTTestModel *model = [[[RTTestModel class] alloc] init];
                [beanUnit setBeanWith:model andDictionary:obj];
                
                NSLog(@"%@",model.tableAreaName);
                NSLog(@"%@",model.tableAreaID);
                NSLog(@"%@",model.date);
            }];
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
