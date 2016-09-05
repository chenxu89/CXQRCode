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
    for (CIFeature *feature in features){
//        NSLog(@"%@", feature);
        CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
        NSLog(@"%@", qrFeature.messageString);
        NSLog(@"%@", NSStringFromCGRect(qrFeature.bounds));
    }
    
}

@end
