//
//  QRCodeTool.h
//  二维码
//
//  Created by chenxu on 16/9/6.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Singleton.h"

//定义一个block类型
typedef void (^ScanCompletionBlock)(NSArray *resultStrs);

@interface QRCodeTool : NSObject
single_interface(QRCodeTool)
/**
 *  生成二维码图片
 *
 *  @param inputStr    内容字符串
 *  @param centerImage 中心图片，可为nil
 *
 *  @return 返回的二维码图片
 */
+ (UIImage *)generatorQRCode:(NSString *)inputStr centerImage:(UIImage *)centerImage;

/**
 *  识别图片中的二维码
 *
 *  @param image             原始图片
 *  @param isDrawQRCodeFrame 是否给识别出的二维码画出边框，如果为YES会修改传入的图片，生成新的图片
 *
 *  @return 字典，resultImage:新图片，strArray:识别出的字符串内容数组
 */
+ (NSDictionary *)detectorQRCodeImage:(UIImage *)image isDrawQRCodeFrame:(BOOL)isDrawQRCodeFrame;

/**
 *  扫描二维码
 *
 *  @param inView            预览图层添加到这个view上
 *  @param isDrawQRCodeFrame 是否给识别出的二维码画出边框
 *  @param interestRect      扫描的兴趣区域，哪个区域可以识别二维码
 *  @param completion        扫描的结果处理block
 */
- (void)scanQRCode:(UIView *)inView isDrawQRCodeFrame:(BOOL)isDrawQRCodeFrame interestRect:(CGRect)interestRect completion:(ScanCompletionBlock)completion;
@end
