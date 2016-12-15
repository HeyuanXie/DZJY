//
//  ViewController.h
//  AddressPickerView
//
//  Created by zeasn on 16/9/6.
//  Copyright © 2016年 zeasn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectFinished)(NSString* text);

@interface AddressSelectViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIButton *addressBtn;
    NSArray *provinceArray;//省的数组
    NSArray *cityArray;//市的数组
    NSArray *districtArray;//区的数组
    
    
    NSString *provinceStr;//省的名字
    NSString *provinceId;//省id
    NSString *cityStr;//市的名字
    NSString *districtStr;//区的名字

    
    NSMutableDictionary *cityDic ;
    NSMutableDictionary *districtDic;

    UIView *baseView;
    UIView *_pickerView;
    
    UIPickerView *picker;
}

@property(nonatomic,copy) SelectFinished finished;

@end

