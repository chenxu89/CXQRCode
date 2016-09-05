//
//  DetectorQRCodeVC.m
//  二维码
//
//  Created by chenxu on 16/9/5.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "DetectorQRCodeVC.h"
#import <CoreImage/CoreImage.h>

@interface DetectorQRCodeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *souceImageView;

@end

@implementation DetectorQRCodeVC
- (IBAction)detectQRCode {
    // 1.获取需要识别的图片
    UIImage *image = self.souceImageView.image;
//    CIImage *imageCI = image.CIImage;//这样得到的imageCI是nil
    CIImage *imageCI = [[CIImage alloc] initWithCGImage:image.CGImage];
    // 2.创建一个二维码探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    // 3.直接探测二维码特征
    NSArray *features = [detector featuresInImage:imageCI];
    UIImage *resultImage = image;
    NSMutableArray *result = [NSMutableArray array];
    for (CIFeature *feature in features){
//        NSLog(@"%@", feature);
        CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
//        NSLog(@"%@", qrFeature.messageString);
        [result addObject:qrFeature.messageString];
//        NSLog(@"%@", NSStringFromCGRect(qrFeature.bounds));
        resultImage = [self drawFrame:resultImage feature:qrFeature];
    }
    self.souceImageView.image = resultImage;
    NSLog(@"%@", result);
    // 将识别的文字弹窗显示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:result.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (UIImage *)drawFrame:(UIImage *)image feature:(CIQRCodeFeature *)feature
{
    CGSize size = image.size;
    // 1.开启图形上下文
    UIGraphicsBeginImageContext(size);
    // 2.绘制大图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 转换坐标系（上下颠倒）
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    // 3.绘制路径
    CGRect bounds = feature.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:bounds];
    [path setLineWidth:2];
    [[UIColor redColor] setStroke];
    [path stroke];
    // 4.取出结果图片
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // 5.关闭上下文
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
