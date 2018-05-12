//
//  HTMISettingManager.h
//  MXClient
//
//  Created by wlq on 16/6/14.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef HTMIApplicationHueType_h
#define HTMIApplicationHueType_h
typedef NS_ENUM(NSInteger, HTMIApplicationHueType) {
    HTMIApplicationHueWhite = 0,           //默认
    HTMIApplicationHueRed = 1,            //第一个字符.
    HTMIApplicationHueBlue = 2
};

#endif /* HTMIHeaderImageType_h */

@interface HTMISettingManager : NSObject

+ (instancetype)manager;

/** 导航栏按钮字体大小（用来设置自定义View导航栏）*/
@property (nonatomic, copy ,readonly) UIFont *applicatioNavigationBarButtonItemTitleFontSize;

/** 导航栏标题字体大小（用来设置自定义View导航栏）*/
@property (nonatomic, copy ,readonly) UIFont *applicatioNavigationBarTitleFontSize;

/** 默认的蓝色色调的色值 */
@property (nonatomic, copy ,readonly) UIColor *applicationDefaultBlueColor;

/** 导航栏标题字体 （用来设置系统导航栏） */
@property (nonatomic, copy ,readonly) NSDictionary *applicationNavigationBarTitleFontDic;

/** 导航栏按钮字体 （用来设置系统导航栏） */
@property (nonatomic, copy ,readonly) NSDictionary *applicationNavigationBarButtonItemTitleFontDic;

/**
 *  导航栏颜色
 */
@property (nonatomic, copy ,readonly) UIColor *navigationBarColor;

/**
 *  导航栏按钮颜色
 */
@property (nonatomic, copy ,readonly) UIColor *navigationBarButtonColor;

/**
 *  普通控件颜色（根据导航栏色调配置）
 */
@property (nonatomic, copy ,readonly) UIColor *controlColor;

/**
 *  导航栏字体颜色
 */
@property (nonatomic, copy ,readonly) UIColor *navigationBarTitleFontColor;

/**
 *  选项卡控件背景色
 */
@property (nonatomic, copy ,readonly) UIColor *segmentedControlBackgroundColor;

/**
 *  选项卡控件色调
 */
@property (nonatomic, copy ,readonly) UIColor *segmentedControlTintColor;

/**
 *  随机色
 */
@property (nonatomic, copy ,readonly) UIColor *randomColor;

/**
 *  应用色调
 */
@property (nonatomic, assign ,readonly) HTMIApplicationHueType applicationHue;

/**
 应用中心列数
 */
@property (nonatomic, assign ,readonly) NSInteger appColumnNumber;

/**
 门户默认字体大小Style-1 ~ 3
 */
@property (nonatomic, assign ,readonly) NSInteger portalDefaultFontStyle;

/**
 用户设置的门户字体大小-1 ~ 3
 */
@property (nonatomic, assign ,readonly) NSInteger customPortalFontStyle;

/**
 我们可以使用的字体大小1~5
 */
@property (nonatomic, assign ,readonly) NSInteger fontSizeCoefficient;

/**
 *  选择页面页签的高度
 */
@property (nonatomic, assign)NSInteger choosePageTagHight;

/**
 设置字体样式

 @param fontSizeStyle 字体大小样式
 */
- (void)setupPortalDefaultFontSizeStyle:(NSInteger)fontSizeStyle;

/**
 设置自定义门户字体大小样式
 
 @param fontSizeStyle 字体大小样式
 */
- (void)setupCustomPortalFontStyle:(NSInteger)fontSizeStyle;

/**
 设置色调类型

 @param applicationHue 色调类型
 */
- (void)setUpApplicationHue:(HTMIApplicationHueType)applicationHue;

/**
 设置Tabbar的样式
 
 @param tabBarController tabbar控制器
 @param font 字体大小
 */
- (void)setUpTabbarStyle:(UITabBarController *)tabBarController
          tabBarItemFont:(UIFont *)font;

/**
 设置整个应用的导航栏标题字体
 
 @param font 字体
 */
- (void)setupApplicatioNavigationBarTitleFont:(UIFont *)font;

/**
 设置整个应用的导航栏按钮字体
 
 @param font 字体
 */
- (void)setupApplicatioNavigationBarButtonItemTitleFont:(UIFont *)font;

/**
 设置应用中心列数

 @param columnNumber 列数
 */
- (void)setupAppCenterColumnNumber:(NSInteger)columnNumber;

@end
