//
//  RTBean.h
//  RTBeanUnitDemo
//
//  Created by 唐 嘉宾 on 13-5-8.
//  Copyright (c) 2013年 唐 嘉宾. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTBean : NSObject
{
    NSString *abc;
    int efg;
}
@property(nonatomic,assign)int intNum;
@property(nonatomic,assign)float floatNum;
@property(nonatomic,strong)NSDate *date;
@property(nonatomic,strong)NSString *string;

-(void)defualt;
@end
