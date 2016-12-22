//
//  ViewController.m
//  AddressPickerView
//
//  Created by zeasn on 16/9/6.
//  Copyright © 2016年 zeasn. All rights reserved.
//

#import "AddressSelectViewController.h"
//获取物理屏幕的尺寸
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
@interface AddressSelectViewController ()

@end

@implementation AddressSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPickview];
    // Do any additional setup after loading the view, typically from a nib.
}

//创建pickview
- (void)createPickview
{
    //从plist中获取数组和字典
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"xml"];
    NSString *str = [NSString stringWithContentsOfFile:plistPath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *listDic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    NSDictionary *areaDic = [listDic objectForKey:@"list"];
    provinceArray = [areaDic objectForKey:@"province"];
    
    //所有省对应的城市和区
    cityDic = [[NSMutableDictionary alloc]init];
    districtDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i<provinceArray.count; i++) {
        NSDictionary *proviceDic = [provinceArray objectAtIndex:i];
        provinceStr = [proviceDic objectForKey:@"name"];//省
        provinceId = [proviceDic objectForKey:@"id"];//省id
        //因为xml文件中存在直辖市等的city类型是字典 而正常的省会是数组 所以加以区分
        if ([[proviceDic objectForKey:@"city"] isKindOfClass:[NSArray class]]) {
            cityArray = [proviceDic objectForKey:@"city"];//城市
            for (int i = 0; i<cityArray.count; i++) {
                NSDictionary *cityADic = [cityArray objectAtIndex:i];
                cityStr = [cityADic objectForKey:@"name"];//城市
                districtArray = [cityADic objectForKey:@"region"];
                if (districtArray.count != 0) {
                    //存入字典 城市 对应 区县
                    [districtDic setObject:districtArray forKey:cityStr];
                }
                
            }
            //存入字典 省对应城市
            [cityDic setObject:cityArray forKey:provinceStr];
        }
        else if ([[proviceDic objectForKey:@"city"] isKindOfClass:[NSDictionary class]])
        {
            
            NSMutableArray *cityarray=[NSMutableArray array];
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            [dic setObject:provinceStr forKey:@"name"];
            [dic setObject:provinceId forKey:@"id"];
            [cityarray addObject:dic];
            //                //存入字典 省对应城市
            [cityDic setObject:cityarray forKey:provinceStr];
            NSDictionary *cityArray1 = [proviceDic objectForKey:@"city"];
            districtArray = [cityArray1 objectForKey:@"region"];
            if (districtArray.count != 0) {
                //存入字典 城市 对应 区县
                [districtDic setObject:districtArray forKey:provinceStr];
            }
        }
    }
    
    //透明黑
    baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth,kScreenHeight)];
   baseView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    
    UITapGestureRecognizer *baseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(baseViewTapAction:)];
    [baseView addGestureRecognizer:baseViewTap];
    [self.view addSubview:baseView];
//    [self.view.window addSubview:baseView];
    _pickerView = [[UIView alloc] initWithFrame:CGRectMake(30, (kScreenHeight-300)/2, kScreenWidth-60, 300)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.layer.cornerRadius = 9.0;
    
    [baseView addSubview:_pickerView];
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 190, _pickerView.frame.size.width, .5)];
    lineLabel.backgroundColor = [self colorWithHexString:@"#dadada"];
    [_pickerView addSubview:lineLabel];
    
    CGFloat btnWhidth=(kScreenWidth-60)/2;
    
    //取消
    UIButton *cancleBt = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBt.frame = CGRectMake(0, 240+10, btnWhidth, 35);
    [cancleBt setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBt addTarget:self action:@selector(cancleAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBt setTitleColor:[self colorWithHexString:@"#141414"] forState:UIControlStateNormal];
    [_pickerView addSubview:cancleBt];
    
    //确定
    UIButton *confirmBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBt addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    confirmBt.frame = CGRectMake(btnWhidth, 240+10, btnWhidth, 35);
    [confirmBt setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBt setTitleColor:[self colorWithHexString:@"#141414"] forState:UIControlStateNormal];
    [_pickerView addSubview:confirmBt];
    
    //picker
    picker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, 10, kScreenWidth-60, 250)];
    picker.dataSource = self;
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    [picker selectRow: 0 inComponent:0 animated: YES];
    [picker reloadAllComponents];
    NSInteger rowProvince = [picker selectedRowInComponent:0];
    NSString *provinceName = provinceArray[rowProvince][@"name"];
    cityArray = cityDic[provinceName];
    NSInteger rowCity = [picker selectedRowInComponent:1];
    NSString *cityName =cityArray[rowCity][@"name"];
    districtArray = districtDic[cityName];
//    _componentWithThreeNum=country.count;
//    _componentWithThreeArr=country;
//    cityId =citys[0][@"id"];
//    districtId = _str3[0][@"id"];
    [_pickerView addSubview:picker];
}
#pragma mark- Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component==0  ) {
        return provinceArray.count;
    }
    else if (component==1 ) {
        
        return cityArray.count;
        
    }
    else {
        
        return districtArray.count;
    }
}
#pragma mark - 该方法返回的NSString将作为UIPickerView中指定列和列表项的标题文本
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (0 == component) {
       
        provinceStr =provinceArray[row][@"name"];
        return provinceStr;
    }
    if(1 == component){
        cityStr = cityArray[row][@"name"];
        return cityStr;
        
    }
    else{
        
        if ([districtArray isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic=(NSDictionary *)districtArray;
            districtStr = dic[@"name"];

        }else
        {
            districtStr = districtArray[row][@"name"];
        }
        
         return districtStr;
        
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.frame = CGRectMake(0, 0, ((kScreenWidth-60)-40)/3, 30);
        pickerLabel.numberOfLines = 0;
        pickerLabel.textAlignment=NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
{
    
    return (kScreenWidth-60)/3;
}
#pragma mark - 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(0 == component){
        NSInteger rowProvince = [picker selectedRowInComponent:0];
        NSString *provinceName = provinceArray[rowProvince][@"name"];
        cityArray = cityDic[provinceName];
        [pickerView reloadAllComponents];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        NSInteger rowCity = [picker selectedRowInComponent:1];
        //防止pickerView某列还在滑动中  而选择另一行时 引起崩溃
        if (cityArray.count-1<rowCity) {
            
        }else{
            NSString *cityName =cityArray[rowCity][@"name"];
            districtArray = districtDic[cityName];
            [pickerView reloadAllComponents];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
        }
    }
    else if(1 == component)
    {
        NSInteger rowProvince = [picker selectedRowInComponent:0];
        NSString *provinceName = provinceArray[rowProvince][@"name"];
        cityArray = cityDic[provinceName];
        NSInteger rowCity = [picker selectedRowInComponent:1];
        if (cityArray.count-1<rowCity) {
            
        }else{
            NSString *cityName =cityArray[rowCity][@"name"];
            districtArray= districtDic[cityName];
            [pickerView reloadAllComponents];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
        }
    }else
    {
        [pickerView reloadAllComponents];
    }
    
}


#pragma mark -UIButton action
- (void)baseViewTapAction:(UITapGestureRecognizer *)tap
{
    
}

- (void)cancleAction:(UIButton *)sender
{
    [baseView removeFromSuperview];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)confirmAction:(UIButton *)sender
{
    
    NSString* text = [NSString stringWithFormat:@"%@ %@ %@",provinceStr,cityStr,districtStr];
    [baseView removeFromSuperview];
    [self dismissViewControllerAnimated:true completion:^{
        self.finished(text);
    }];
}
#pragma mark-颜色
- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
