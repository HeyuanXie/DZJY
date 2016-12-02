//
//  ShareSDKThirdLoginHelper.m
//  ZhiMaDi
//
//  Created by haijie on 16/7/4.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

#import "ShareSDKThirdLoginHelper.h"
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>

@interface ShareSDKThirdLoginHelper ()

@property(nonatomic,assign)SSDKPlatformType loginPlatform;

@end

@implementation ShareSDKThirdLoginHelper : NSObject

-(void)loginWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
            self.loginPlatform = SSDKPlatformTypeWechat;
            break;
        case 1:
            self.loginPlatform = SSDKPlatformTypeSinaWeibo;
            break;
        default:
            self.loginPlatform = SSDKPlatformTypeQQ;
            break;
    }
    [SSEThirdPartyLoginHelper loginByPlatform:self.loginPlatform
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       
                                       //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
                                       //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
                                       associateHandler (user.uid, user, user);
                                       NSLog(@"dd%@",user.rawData);
                                       NSLog(@"dd%@",user.credential);
                                       
                                       /*UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Text" message:[NSString stringWithFormat:@"%@,%@,%@",user.nickname,user.credential.uid,user.credential.token] preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                                       [alert addAction:action];*/
                                       
                                       NSString* nickName = user.nickname;
                                       NSString* icon = user.icon;
                                       NSString* password = @"111111";
                                       [self.delegate loginWithName:nickName andPassWord:password andIcon:icon];
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    if (state == SSDKResponseStateSuccess)
                                    {
                                        NSLog(@"successed");
                                    }
                                    
                                }];

}





@end

