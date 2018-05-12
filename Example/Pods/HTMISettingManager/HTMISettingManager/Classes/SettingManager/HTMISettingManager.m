//
//  HTMISettingManager.m
//  MXClient
//
//  Created by wlq on 16/6/14.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMISettingManager.h"


@interface HTMISettingManager()

/**
 *  导航栏颜色
 */
@property (nonatomic, copy ,readwrite) UIColor *navigationBarColor;

/**
 *  导航栏按钮颜色
 */
@property (nonatomic, copy ,readwrite) UIColor *navigationBarButtonColor;

/**
 *  普通控件颜色（根据导航栏色调配置）
 */
@property (nonatomic, copy ,readwrite) UIColor *controlColor;

/**
 *  导航栏字体颜色
 */
@property (nonatomic, copy ,readwrite) UIColor *navigationBarTitleFontColor;

/**
 *  选项卡控件背景色
 */
@property (nonatomic, copy ,readwrite) UIColor *segmentedControlBackgroundColor;

/**
 *  选项卡控件色调
 */
@property (nonatomic, copy ,readwrite) UIColor *segmentedControlTintColor;

/**
 门户默认字体大小Style-1 ~ 3
 */
@property (nonatomic, assign ,readwrite) NSInteger portalDefaultFontStyle;

/**
 用户设置的门户字体大小-1 ~ 3
 */
@property (nonatomic, assign ,readwrite) NSInteger customPortalFontStyle;

/**
 我们可以使用的字体大小1~5
 */
@property (nonatomic, assign ,readwrite) NSInteger fontSizeCoefficient;

/** 导航栏按钮字体大小（用来设置自定义View导航栏）*/
@property (nonatomic, copy ,readwrite) UIFont *applicatioNavigationBarButtonItemTitleFontSize;

/** 导航栏标题字体大小（用来设置自定义View导航栏）*/
@property (nonatomic, copy ,readwrite) UIFont *applicatioNavigationBarTitleFontSize;

/** 默认的蓝色色调的色值 */
@property (nonatomic, copy ,readwrite) UIColor *applicationDefaultBlueColor;

/** 导航栏标题字体 （用来设置系统导航栏） */
@property (nonatomic, copy ,readwrite) NSDictionary *applicationNavigationBarTitleFontDic;

/** 导航栏按钮字体 （用来设置系统导航栏） */
@property (nonatomic, copy ,readwrite) NSDictionary *applicationNavigationBarButtonItemTitleFontDic;

/**
 *  随机色
 */
@property (nonatomic, copy ,readwrite) UIColor *randomColor;

/**
 应用中心列数
 */
@property (nonatomic, assign ,readwrite) NSInteger appColumnNumber;

@end

@implementation HTMISettingManager

@synthesize applicationHue = _applicationHue;

static id _manager = nil;
// 返回单例
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super alloc] init];
    });
    
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _customPortalFontStyle = -10;
        _applicationDefaultBlueColor = [UIColor colorWithRed:70/255.0 green:76/255.0 blue:98/255.0 alpha:1.0];
        //        _applicatioNavigationBarTitleFontSize = [UIFont myFontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
        //        _applicatioNavigationBarButtonItemTitleFontSize = [UIFont myFontWithName:@"HelveticaNeue-CondensedBlack" size:14.0];
    }
    return self;
}

/**
 设置整个应用的导航栏标题字体
 
 @param font 字体
 */
- (void)setupApplicatioNavigationBarTitleFont:(UIFont *)font {
    _applicatioNavigationBarTitleFontSize = font;
}

/**
 设置整个应用的导航栏按钮字体
 
 @param font 字体
 */
- (void)setupApplicatioNavigationBarButtonItemTitleFont:(UIFont *)font {
    _applicatioNavigationBarButtonItemTitleFontSize = font;
}

- (NSDictionary *)applicationNavigationBarTitleFontDic {
    
    _applicationNavigationBarTitleFontDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [HTMISettingManager manager].navigationBarTitleFontColor,NSForegroundColorAttributeName,
                                             [HTMISettingManager manager].applicatioNavigationBarTitleFontSize,
                                             NSFontAttributeName,nil];
    
    return _applicationNavigationBarTitleFontDic;
}

- (NSDictionary *)applicationNavigationBarButtonItemTitleFontDic {
    _applicationNavigationBarButtonItemTitleFontDic = [NSDictionary dictionaryWithObjectsAndKeys:[HTMISettingManager manager].navigationBarTitleFontColor,NSForegroundColorAttributeName, [HTMISettingManager manager].applicatioNavigationBarButtonItemTitleFontSize,
                                                       NSFontAttributeName,nil];
    
    return _applicationNavigationBarButtonItemTitleFontDic;
}

- (NSInteger)fontSizeCoefficient{
    //门户默认
    NSInteger fontStyle = 0;
    //门户设置的默认的
    //判断本地表是否有记录
    
    fontStyle = _customPortalFontStyle;
    
    if (fontStyle <= -10){//判断是否自定义了字体大小
        
        fontStyle = _portalDefaultFontStyle;
    }
    
    
    NSInteger value =  fontStyle + 2;
    if (value < 1) {
        value = 1;
    }
    else if(value > 5){
        value = 5;
    }
    
    return value;
}

- (void)setUpApplicationHue:(HTMIApplicationHueType)applicationHue{
    
    _applicationHue = applicationHue;
}

- (HTMIApplicationHueType)applicationHue {
    
    return _applicationHue;
}

- (UIColor *)navigationBarColor {
    
    int hue = [HTMISettingManager manager].applicationHue;
    if (hue == HTMIApplicationHueWhite) {
        return [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    }
    else if (hue == HTMIApplicationHueRed) {
        return [UIColor colorWithRed:223/255.0 green:48/255.0 blue:49/255.0 alpha:1.0];
    }
    else if (hue == HTMIApplicationHueBlue) {
        return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    }
    else{
        return [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];//默认白色导航栏
    }
}

- (UIColor *)navigationBarButtonColor {
    
    if ([HTMISettingManager manager].applicationHue == HTMIApplicationHueWhite) {
        
        return [HTMISettingManager manager].applicationDefaultBlueColor;
    }
    else{
        
        return [UIColor whiteColor];
    }
}

- (UIColor *)controlColor {
    
    if ([HTMISettingManager manager].applicationHue == HTMIApplicationHueWhite) {//如果是白色色调
        
        return [HTMISettingManager manager].applicationDefaultBlueColor;
    }
    else{
        return [HTMISettingManager manager].navigationBarColor;
    }
}

- (UIColor *)navigationBarTitleFontColor {
    
    
    if ([HTMISettingManager manager].applicationHue == HTMIApplicationHueWhite) {//如果是白色色调，导航栏字体颜色需要改成黑色
        _navigationBarTitleFontColor = [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
    }
    else{
        _navigationBarTitleFontColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    }
    return _navigationBarTitleFontColor;
}

- (UIColor *)segmentedControlBackgroundColor {
    
    
    if ([HTMISettingManager manager].applicationHue == HTMIApplicationHueWhite) {//如果是白色色调
        _segmentedControlBackgroundColor = [UIColor whiteColor];
    }
    else{
        _segmentedControlBackgroundColor = [HTMISettingManager manager].navigationBarColor;
    }
    
    return   _segmentedControlBackgroundColor;
}

- (UIColor *)segmentedControlTintColor{
    
    if ([HTMISettingManager manager].applicationHue == HTMIApplicationHueWhite) {//如果是白色色调
        _segmentedControlTintColor = [HTMISettingManager manager].applicationDefaultBlueColor;
    }
    else{
        _segmentedControlTintColor = [UIColor whiteColor];
    }
    
    return   _segmentedControlTintColor;
}

- (UIColor *)randomColor {
    
    ///取名字的32位md5最后一位  对应的  ASCII 十进制值 的末尾值 ( 0 - 9 ) 对应的颜色为底色
    NSInteger index = arc4random() % 10;//(NSInteger)[[string md5_32] characterAtIndex:31];
    //约定的颜色值
    NSString *colorHex = @"0DB8F6,00D3A3,FCD240,F26C13,EE523D,4C90FB,FFBF45,48A6DF,00B25E,EC606C";
    NSArray *colorHexArray = [colorHex componentsSeparatedByString:@","];
    //取到颜色值
    _randomColor = [self p_colorFromHexCode:[colorHexArray objectAtIndex:index]];
    
    return _randomColor;
}

/**
  设置Tabbar的样式

 @param tabBarController tabbar控制器
 @param font 字体大小
 */
- (void)setUpTabbarStyle:(UITabBarController *)tabBarController
          tabBarItemFont:(UIFont *)font {
    //[UIFont mySystemFontOfSize:13.0]
    //设置底部导航栏样式，字体大小不随应用字体大小改变
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName :  [HTMISettingManager manager].controlColor,NSFontAttributeName : font}
                                             forState:UIControlStateHighlighted];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : font }
                                             forState:UIControlStateNormal];
    
    [[UITabBar appearance]setTintColor:[HTMISettingManager manager].controlColor];
    
    [tabBarController.tabBar setTintColor:[HTMISettingManager manager].controlColor];//直接进行修改
}

/**
 设置字体样式
 
 @param fontSizeStyle 字体大小样式
 */
- (void)setupPortalDefaultFontSizeStyle:(NSInteger)fontSizeStyle {
    _portalDefaultFontStyle = fontSizeStyle;
}

/**
 设置自定义门户字体大小样式
 
 @param fontSizeStyle 字体大小样式
 */
- (void)setupCustomPortalFontStyle:(NSInteger)fontSizeStyle {
    _customPortalFontStyle = fontSizeStyle;
}

/**
 设置应用中心列数
 
 @param columnNumber 列数
 */
- (void)setupAppCenterColumnNumber:(NSInteger)columnNumber {
    _appColumnNumber = columnNumber;
}

#pragma mark - 私有方法

- (UIColor *)p_colorFromHexCode:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


@end
