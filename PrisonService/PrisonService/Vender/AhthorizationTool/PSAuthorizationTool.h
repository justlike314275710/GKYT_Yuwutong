//
//  STAuthorizationTool.h
//  Start
//
//  Created by calvin on 17/2/17.
//  Copyright © 2017年 DingSNS. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, PSAuthorizationType) {
    PSLocation = 0, //定位
};

typedef void (^CheckAuthorizationBlock)(BOOL result);

@interface PSAuthorizationTool : NSObject


/**
 *  检测相机和麦的使用权限
 *  @param block 结果回调
 */
+ (void)checkAndRedirectAVAuthorizationWithBlock:(CheckAuthorizationBlock)block;

//视屏通话检查权限
+ (void)viode_checkAndRedirectAVAuthorizationWithBlock:(CheckAuthorizationBlock)block;
/**
 *  检测相机的使用权限
 *  @param block 结果回调
 */
+ (void)checkAndRedirectCameraAuthorizationWithBlock:(CheckAuthorizationBlock)block;
/**
 *  检测相册的使用权限
 *  @param block 结果回调
 */
+ (void)checkAndRedirectPhotoAuthorizationWithBlock:(CheckAuthorizationBlock)block;
/**
 *  检测麦的使用权限
 *  @param block 结果回调
 */
+ (void)checkAndRedirectAudioAuthorizationWithBlock:(CheckAuthorizationBlock)block;
+ (BOOL)isAudioAvailable;

//获取权限
+(BOOL)checkAuthorizationWithType:(PSAuthorizationType)type;
+(void)showAuthTitle:(NSString *)title message:(NSString *)message btnTitle:(NSString *)btnTitle;


@end
