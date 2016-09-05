//
//  GeneratorQRCodeVC.m
//  二维码
//
//  Created by chenxu on 16/9/5.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "GeneratorQRCodeVC.h"
#import <CoreImage/CoreImage.h>

@interface GeneratorQRCodeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UITextView *inputTV;

@end

@implementation GeneratorQRCodeVC
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.inputTV endEditing:YES];
    NSString *dataString = self.inputTV.text ? self.inputTV.text: @"";
    // 1.创建二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 1.1恢复滤镜默认设置
    [filter setDefaults];
    // 2.设置滤镜输入数据
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    // KVC
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 设置二维码的纠错率
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 3.从二维码滤镜里面，获取结果图片
    CIImage *image = filter.outputImage;
    // 图片处理
    // 默认生成的图片大小是（23，23），如果需要生成高清图片，需要用CGAffineTransform放大
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    UIImage *resultImage = [UIImage imageWithCIImage:image];
    // 前景图片
    UIImage *centerImage = [UIImage imageNamed:@"erha.png"];
    resultImage = [self getNewImageSourceImage:resultImage centerImage:centerImage];
    // 4.显示图片
    self.qrCodeImageView.image = resultImage;
    
}

- (UIImage *)getNewImageSourceImage:(UIImage *)souceImage centerImage:(UIImage *)centerImage{
    CGSize size = souceImage.size;
    // 1.开启图形上下文
    UIGraphicsBeginImageContext(size);
    // 2.绘制大图片
    [souceImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 3.绘制小图片
    CGFloat width = 80;
    CGFloat height = 80;
    CGFloat x = (size.width - width) * 0.5;
    CGFloat y = (size.height - height) * 0.5;
    [centerImage drawInRect:CGRectMake(x, y, width, height)];
    // 4.取出结果图片
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // 5.关闭图形上下文
    UIGraphicsEndImageContext();
    // 6.返回结果
    return resultImage;
}
@end
