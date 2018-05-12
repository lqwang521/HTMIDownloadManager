
//
//  [NSUserDefaults standardUserDefaults].m
//  Express
//
//  Created by admin on 15/6/16.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "HTMIUserdefaultHelper.h"
#import "HTMISettingManager.h"

@implementation HTMIUserdefaultHelper

static NSString * const UserdefaultHelper_First_Start = @"firstStartMXApp";
static NSString * const UserdefaultHelper_PortalID = @"htmi_portalId";
static NSString * const UserdefaultHelper_AppId = @"htmi_appId";
static NSString * const UserdefaultHelper_UserId = @"UserID";
static NSString * const UserdefaultHelper_Style = @"fengge";
static NSString * const UserdefaultHelper_Latitude = @"location.coordinate.latitude";
static NSString * const UserdefaultHelper_Longitude = @"location.coordinate.longitude";
static NSString * const UserdefaultHelper_FirstloadAppCenterDataFromDB = @"HTMI_firstloadAppCenterDataFromDB";
static NSString * const UserdefaultHelper_CircleFirstStart = @"circleFirstStart";
static NSString * const UserdefaultHelper_AppCenterFirstStart = @"appCenterFirstStart";
static NSString * const UserdefaultHelper_WorkFlowComponentFirstStart = @"workFlowComponentFirstStart";
static NSString * const UserdefaultHelper_MatterFlowFirstStart = @"matterFlowFirstStart";
static NSString * const UserdefaultHelper_LoginName = @"HTMILoginName";
static NSString * const UserdefaultHelper_NotificationArray = @"notificationArray";
static NSString * const UserdefaultHelper_IsEMIUser = @"htmi_IsEMIUser";
static NSString * const UserdefaultHelper_OAUserId = @"OA_UserId";
static NSString * const UserdefaultHelper_AddressBookSynchronizationeventStamp = @"AddressBookSynchronizationeventStamp";
static NSString * const UserdefaultHelper_AddressBookPath = @"htmi_db";
static NSString * const UserdefaultHelper_HasSetFontSize = @"HasSetFontSize";
static NSString * const UserdefaultHelper_FontSizeCoefficient = @"HTMIFontSizeCoefficient";
static NSString * const UserdefaultHelper_AppCurrentVersionId = @"htmi_AppCurrentVersionId";
static NSString * const UserdefaultHelper_RefreshToken = @"htmiRefreshToken";
static NSString * const UserdefaultHelper_ContextDictionary = @"kContextDictionary";
static NSString * const UserdefaultHelper_PortalIDArray = @"HTMIPortalIDArray";
static NSString * const UserdefaultHelper_AccessToken = @"htmiAccessToken";
static NSString * const UserdefaultHelper_UserPassWord = @"HTMIUserPassWord";
static NSString * const UserdefaultHelper_FontEditePageCoefficient = @"FontEditePageCoefficient";
static NSString * const UserdefaultHelper_TempLoginName = @"HTMITempLoginName";
static NSString * const UserdefaultHelper_BodyFilePath = @"htmi_BodyFilePath";


static NSUserDefaults * userdefaultHelperShareNSUserDefaults;


/**
 设置共享的UserDefaults
 
 @param sharedUserDefaults 共享的UserDefaults
 */
+ (void)setupSharedUserDefaults:(NSUserDefaults *)sharedUserDefaults {
    userdefaultHelperShareNSUserDefaults = sharedUserDefaults;
}

/**
 数据共享的UserDefaults
 */
+ (NSUserDefaults *)sharedUserDefaults {
    return userdefaultHelperShareNSUserDefaults;
}

/**
  清除UserDefaults（切换用户）
 */
+ (void)clearCache {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@{}  forKey:UserdefaultHelper_ContextDictionary];
    [userDefaults setObject:@[]  forKey:UserdefaultHelper_PortalIDArray];
    [userDefaults setObject:@""  forKey:UserdefaultHelper_UserId];
    [userDefaults setObject:@"" forKey:UserdefaultHelper_OAUserId];
    [userDefaults setObject:@""  forKey:UserdefaultHelper_PortalID];
    [userDefaults setObject:@""  forKey:UserdefaultHelper_AddressBookSynchronizationeventStamp];//清除时间戳，会重新同步本地数据库
    [userDefaults removeObjectForKey:UserdefaultHelper_AppId];
    [userDefaults removeObjectForKey:UserdefaultHelper_Style];
    [userDefaults removeObjectForKey:UserdefaultHelper_Latitude];
    [userDefaults removeObjectForKey:UserdefaultHelper_Longitude];
    [userDefaults removeObjectForKey:UserdefaultHelper_FirstloadAppCenterDataFromDB];
    [userDefaults removeObjectForKey:UserdefaultHelper_CircleFirstStart];
    [userDefaults removeObjectForKey:UserdefaultHelper_AppCenterFirstStart];
    [userDefaults removeObjectForKey:UserdefaultHelper_WorkFlowComponentFirstStart];
    [userDefaults removeObjectForKey:UserdefaultHelper_MatterFlowFirstStart];
    [userDefaults removeObjectForKey:UserdefaultHelper_LoginName];
    
    [userDefaults synchronize];
    //[userDefaults removeObjectForKey:UserdefaultHelper_IsEMIUser]; 这个不能清空，因为退出是依靠这个字段判断使用敏行的退出方法还是直接使用我们自己的退出方法
}

/**
 推送字典数组
 
 @return 推送字典数组
 */
+ (NSMutableArray*)defaultLoadNotificationArray {
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_NotificationArray] ==  nil ? @[]:[defaults objectForKey:UserdefaultHelper_NotificationArray];
}

+ (void)defaultAddToNotificationArray:(NSDictionary *)a {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self defaultLoadNotificationArray]];
    [arr addObject:a];
    [defaults setObject:arr  forKey:UserdefaultHelper_NotificationArray];
    [defaults synchronize];
}

+ (void)defaultRemoveFirstNotificationArray {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self defaultLoadNotificationArray]];
    if (arr.count > 0) {
        [arr removeObjectAtIndex:0];
    }
    [defaults setObject:arr  forKey:UserdefaultHelper_NotificationArray];
    [defaults synchronize];
}

/**
 保存是否已经设置字体大小
 
 @param coefficient 字体大小
 */
+ (void)defaultSaveNewFontSizeCoefficient:(NSInteger )coefficient{
    
    [[NSUserDefaults standardUserDefaults] setObject:UserdefaultHelper_HasSetFontSize forKey:UserdefaultHelper_HasSetFontSize];
    
    [[NSUserDefaults standardUserDefaults] setInteger:coefficient forKey:UserdefaultHelper_FontSizeCoefficient];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)defaultSaveContext:(NSDictionary *)context {
    //    HTMILogInfo(@"Context:%@",context);
    [[NSUserDefaults standardUserDefaults] setObject:context forKey:UserdefaultHelper_ContextDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)defaultLoadContext {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_ContextDictionary] ==  nil ? @{}:[[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_ContextDictionary];
}

+ (NSInteger)defaultLoadNewFontSizeCoefficient {
    
    return [HTMISettingManager manager].fontSizeCoefficient;
}

+ (float)defaultLoadNewCoefficient {
    
    NSInteger coefficient =[HTMIUserdefaultHelper defaultLoadNewFontSizeCoefficient];
    //    return 0.075*(coefficient-2)+1;
    return 0.1*(coefficient-2)+1;
}

//用户OAID
+ (NSString*)defaultLoadOAUserID{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_OAUserId] ==  nil ? @"":[defaults objectForKey:UserdefaultHelper_OAUserId];
}

+ (void)defaultSaveOAUserID:(NSString *)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_OAUserId];
    [defaults synchronize];
}

//用户ID
+ (NSString*)defaultLoadUserID{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_UserId] ==  nil ? @"":[defaults objectForKey:UserdefaultHelper_UserId];
}

+ (void)defaultSaveUserID:(NSString *)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_UserId];
    [defaults synchronize];
}

//是不是EMIUser
+ (NSString*)defaultLoadIsEMIUser{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_IsEMIUser] ==  nil ? @"":[defaults objectForKey:UserdefaultHelper_IsEMIUser];
}

+ (void)defaultSaveIsEMIUser:(NSString *)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%@",a]  forKey:UserdefaultHelper_IsEMIUser];
    [defaults synchronize];
}

//通讯录同步时间戳
+ (NSString *)defaultLoadAddressBookSynchronizationeventStamp{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_AddressBookSynchronizationeventStamp]  ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_AddressBookSynchronizationeventStamp];
}

+ (void)defaultSaveAddressBookSynchronizationeventStamp:(NSString *)a{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_AddressBookSynchronizationeventStamp];
    [defaults synchronize];
}

//通讯录文件地址
+ (NSString *)defaultLoadAddressBookPath{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_AddressBookPath] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_AddressBookPath];
}

+ (void)defaultSaveAddressBookPath:(NSString *)a{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_AddressBookPath];
    [defaults synchronize];
}

//界面风格
+ (NSString *)defaultLoadViewStyle{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:UserdefaultHelper_Style] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_Style];
}

+ (void)defaultSaveViewStyle:(NSString *)a{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_Style];
    [defaults synchronize];
}

//appid
+ (NSString *)defaultLoadCurrentAppId{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_AppId] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_AppId];
}

+ (void)defaultSaveCurrentAppId:(NSString *)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_AppId];
    [defaults synchronize];
}

//appVersionid
+ (NSString *)defaultLoadCurrentAppVersionId{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_AppCurrentVersionId] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_AppCurrentVersionId];
}

+ (void)defaultSaveCurrentAppVersionId:(NSString *)a {
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_AppCurrentVersionId];
    [defaults synchronize];
}

//refreshToken
+ (NSString *)defaultLoadRefreshToken {
    //    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_RefreshToken] ==  nil ? @"": [[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_RefreshToken];
}

+ (void)defaultSaveRefreshToken:(NSString *)a {
    //    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:a  forKey:UserdefaultHelper_RefreshToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//accessToken
+ (NSString*)defaultLoadAccessToken {
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    return [[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_AccessToken] ==  nil ? @"": [[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_AccessToken];
}

+ (void)defaultSaveAccessToken:(NSString *)a {
    //    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:a  forKey:UserdefaultHelper_AccessToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//PortalID
+ (NSString*)defaultLoadPortalID {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:UserdefaultHelper_PortalID] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_PortalID];
}

+ (void)defaultSavePortalID:(NSString *)a {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_PortalID];
    [defaults synchronize];
}

//PortalIDArray
+ (NSArray*)defaultLoadPortalIDArray {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:UserdefaultHelper_PortalIDArray] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_PortalIDArray];
}

+ (void)defaultSavePortalIDArray:(NSArray *)a {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_PortalIDArray];
    [defaults synchronize];
}

//经度
+ (NSString*)defaultLoadLongitude{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:UserdefaultHelper_Longitude] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_Longitude];
}

+ (void)defaultSaveLongitude:(NSString *)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_Longitude];
    [defaults synchronize];
}

//纬度
+ (NSString*)defaultLoadLatitude{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:UserdefaultHelper_Latitude] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_Latitude];
}

+ (void)defaultSaveLatitude:(NSString *)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_Latitude];
    [defaults synchronize];
}

//第一次从数据库中获取应用中心数据
+ (BOOL)defaultLoadFirstloadAppCenterDataFromDB{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:UserdefaultHelper_FirstloadAppCenterDataFromDB];
}

+ (void)defaultSaveFirstloadAppCenterDataFromDB:(BOOL)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:a forKey:UserdefaultHelper_FirstloadAppCenterDataFromDB];
    [defaults synchronize];
}

//工作圈第一次使用
+ (BOOL)defaultLoadCircleFirstStart{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:UserdefaultHelper_CircleFirstStart];
}

+ (void)defaultSaveCircleFirstStart:(BOOL)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:a  forKey:UserdefaultHelper_CircleFirstStart];
    [defaults synchronize];
}

//应用中心第一次使用
+ (BOOL)defaultLoadAppCenterFirstStart{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:UserdefaultHelper_AppCenterFirstStart];
}

+ (void)defaultSaveAppCenterFirstStart:(BOOL)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:a  forKey:UserdefaultHelper_AppCenterFirstStart];
    [defaults synchronize];
}

//工作流构件第一次使用
+ (BOOL)defaultLoadWorkFlowComponentFirstStart {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:UserdefaultHelper_WorkFlowComponentFirstStart];
}

+ (void)defaultSaveWorkFlowComponentFirstStart:(BOOL)a {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:a  forKey:UserdefaultHelper_WorkFlowComponentFirstStart];
    [defaults synchronize];
}

//流程第一次使用
+ (BOOL)defaultLoadMatterFlowFirstStart{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults boolForKey:UserdefaultHelper_MatterFlowFirstStart];
}

+ (void)defaultSaveMatterFlowFirstStart:(BOOL)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:a  forKey:UserdefaultHelper_MatterFlowFirstStart];
    [defaults synchronize];
}

//应用程序第一次使用
+ (BOOL)defaultLoadSystemFirstStart {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:UserdefaultHelper_First_Start];
}

+ (void)defaultSaveSystemFirstStart:(BOOL)a {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:a  forKey:UserdefaultHelper_First_Start];
    [defaults synchronize];
}

//密码
+ (NSString *)defaultLoadPassWord {
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_UserPassWord]  ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_UserPassWord];
}

+ (void)defaultSavePassWord:(NSString *)a {
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_UserPassWord];
    [defaults synchronize];
}


+ (void)defaultSaveFontEditePageCoefficient:(NSInteger )coefficient{
    
    [[NSUserDefaults standardUserDefaults] setInteger:coefficient forKey:UserdefaultHelper_FontEditePageCoefficient];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)defaultLoadFontEditePageCoefficient{
    return  [[NSUserDefaults standardUserDefaults] integerForKey:UserdefaultHelper_FontEditePageCoefficient];
}

//临时账号
+ (NSString *)defaultLoadTempLoginName {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_TempLoginName];
}

//临时账号
+ (void)defaultSaveTempLoginName:(NSString *)a {
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:UserdefaultHelper_TempLoginName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//账号
+ (NSString *)defaultLoadLoginName {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:UserdefaultHelper_LoginName];
}

+ (void)defaultSaveLoginName:(NSString *)a {
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:UserdefaultHelper_LoginName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeHTMIUserDefaultValueForloginName {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserdefaultHelper_LoginName];
}

/**
 正文
 */
+ (NSString *)defaultLoadBodyFile {
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:UserdefaultHelper_BodyFilePath] ==  nil ? @"": [defaults objectForKey:UserdefaultHelper_BodyFilePath];
}

+ (void)defaultSaveBodyFile:(NSString *)a {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:UserdefaultHelper_BodyFilePath];
    [defaults synchronize];
}

@end
