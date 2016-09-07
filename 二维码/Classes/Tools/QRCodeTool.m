//
//  QRCodeTool.m
//  二维码
//
//  Created by chenxu on 16/9/6.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "QRCodeTool.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>


@interface QRCodeTool ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic, copy) ScanCompletionBlock scanCompletionBlock;
@property (nonatomic, assign) BOOL isDrawQRCodeFrame;
@end

@implementation QRCodeTool

single_implementation(QRCodeTool)

#pragma mark - 懒加载 -
- (AVCaptureDeviceInput *)input{
    if (!_input) {
        // 1. 设置输入
        // 1.1 获取摄像头设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // 1.2 把摄像头设备当做输入设备
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {
//            NSLog(@"%@", error);
        }
    }
    return _input;
}
- (AVCaptureMetadataOutput *)output{
    if (!_output) {
        // 2. 设置输出
        _output = [[AVCaptureMetadataOutput alloc] init];
        // 2.1 设置结果处理的代理
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}
- (AVCaptureSession *)session{
    if (!_session) {
        // 3. 创建会话，连接输入和输出
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}
- (AVCaptureVideoPreviewLayer *)layer{
    if (!_layer) {
        _layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _layer;
}

#pragma mark - 公共方法 -
+ (UIImage *)generatorQRCode:(NSString *)inputStr centerImage:(UIImage *)centerImage{
    
    // 1.创建二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 1.1恢复滤镜默认设置
    [filter setDefaults];
    // 2.设置滤镜输入数据
    NSData *data = [inputStr dataUsingEncoding:NSUTF8StringEncoding];
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
    if (centerImage) {
        resultImage = [self getNewImageSourceImage:resultImage centerImage:centerImage];
    }
    
    return resultImage;
}

+ (NSDictionary *)detectorQRCodeImage:(UIImage *)image isDrawQRCodeFrame:(BOOL)isDrawQRCodeFrame
{
    // 1.获取需要识别的图片
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
        if (isDrawQRCodeFrame) {
            resultImage = [self drawFrame:resultImage feature:qrFeature];
        }
    }
    NSDictionary *dic = @{@"resultImage":resultImage, @"strArray":result};
    return dic;
}
- (void)scanQRCode:(UIView *)inView isDrawQRCodeFrame:(BOOL)isDrawQRCodeFrame interestRect:(CGRect)interestRect completion:(ScanCompletionBlock)completion
{
    // 保存block，扫描结果出来时候再调用
    self.scanCompletionBlock = completion;
    self.isDrawQRCodeFrame = isDrawQRCodeFrame;
    
    // 1. 设置输入
    // 2. 设置输出
    // 3. 创建会话，连接输入和输出
    if (self.input) {
        [self.session removeInput:self.input];//旧的输入设备需要删除，否则第二次进入页面的时候，没法添加输入设备，会直接return
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }else{
//            NSLog(@"无法添加输入设备！");
            return;
        }
    }
    if (self.output) {
        [self.session removeOutput:self.output];
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
        }else{
//            NSLog(@"无法添加输出设备！");
            return;
        }
    }
    
    // 3.1 设置二维码可以识别的码制
    // 设置输出的元数据的类型，必须要在输出添加到会话之后，否则会崩溃
    // output.availableMetadataObjectTypes 或者 AVMetadataObjectTypeQRCode
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    // 设置扫描的兴趣区域
    [self setRectInterest:interestRect];
    
    // 3.2添加视频预览图层(让用户可以看到界面）
    NSArray *sublayers = inView.layer.sublayers;
    if (sublayers == nil || ![sublayers containsObject:self.layer]) {
        self.layer.frame = inView.layer.bounds;
        [inView.layer insertSublayer:self.layer atIndex:0];
    }
    // 4. 启动会话（让输入对象开始采集数据，输出对象开始处理数据）
    [self.session startRunning];
    
    // 法二：用AVCaptureVideoPreviewLayer的方法，且必须要放在[session startRunning];方法之后才有效
    //    output.rectOfInterest = [layer metadataOutputRectOfInterestForRect:self.scanBackView.frame];
}
#pragma mark - 私有方法 -
/**
 *  给一个原始图片中心添加一个小图片
 *
 *  @param souceImage  原始图片
 *  @param centerImage 中心小图
 *
 *  @return 新图片
 */
+ (UIImage *)getNewImageSourceImage:(UIImage *)souceImage centerImage:(UIImage *)centerImage{
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
/**
 *  讲识别的二维码的边框画入原始图片中生成新的图片
 *
 *  @param image   原始图片
 *  @param feature 识别的特征
 *
 *  @return 带识别边框的图片
 */
+ (UIImage *)drawFrame:(UIImage *)image feature:(CIQRCodeFeature *)feature
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
    [path setLineWidth:5];
    [[UIColor redColor] setStroke];
    [path stroke];
    // 4.取出结果图片
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // 5.关闭上下文
    UIGraphicsEndImageContext();
    
    return resultImage;
}

/**
 *  设置扫描的兴趣区域
 *
 *  @param originRect 正常坐标系（previewlayer）中的兴趣区域
 */
- (void)setRectInterest:(CGRect)originRect{
    // 设置扫描 的兴趣区域
    // metadataoutputs坐标系 CGRectMake(0, 0, 1, 1)  取值范围：0.0 - 1.0
    // metadataoutputs坐标系 以右上角为0 0 类似于横屏，x和y互换，宽高互换
    // 需要把previewlayer坐标系中的rect转为metadataoutputs坐标系中的rect ，下面有两种方法
    // 法一：自己计算
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat x = originRect.origin.x / bounds.size.width;
    CGFloat y = originRect.origin.y / bounds.size.height;
    CGFloat width = originRect.size.width / bounds.size.width;
    CGFloat height = originRect.size.height / bounds.size.height;
    self.output.rectOfInterest = CGRectMake(y, x, height, width);
}
#pragma mark --- AVCaptureMetadataOutputObjectsDelegate ---
// 扫描到结果之后调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
//        NSLog(@"test");
    //    NSLog(@"%@", metadataObjects);
    if (self.isDrawQRCodeFrame) {
        [self removeFrameLayer];
    }
    if (metadataObjects == nil || [metadataObjects count] <= 0) return;//这个要放在[self removeFrameLayer];后面，否则最后生成的边框没法移除
    NSMutableArray *resultStrs = [NSMutableArray array];
    for (NSObject *obj in metadataObjects) {
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            // 转换成为, 二维码, 在预览图层上的真正坐标
            // qrCodeObj.corners 代表二维码的四个角, 需要借助视频预览图层转换成为我们需要的可以用的坐标
            AVMetadataObject *resultObj = [self.layer transformedMetadataObjectForMetadataObject:(AVMetadataObject *)obj];
            AVMetadataMachineReadableCodeObject *qrCodeObj = (AVMetadataMachineReadableCodeObject *)resultObj;
            //            NSLog(@"%@", qrCodeObj.stringValue);
            //            NSLog(@"%@", qrCodeObj.corners);
            if (self.isDrawQRCodeFrame) {
                [self drawFrame:qrCodeObj];
            }
            [resultStrs addObject:qrCodeObj.stringValue];
        }
    }
    
    self.scanCompletionBlock(resultStrs);
}
- (void)drawFrame:(AVMetadataMachineReadableCodeObject *)qrCodeObj
{
    
    NSArray *corners = qrCodeObj.corners;
    
    // 1. 借助一个图形层来绘制
    CAShapeLayer *shapLayer = [[CAShapeLayer alloc] init];
    shapLayer.fillColor = [UIColor clearColor].CGColor;
    shapLayer.strokeColor = [UIColor redColor].CGColor;
    shapLayer.lineWidth = 6;
    
    // 2. 根据四个点创建一个路径
    UIBezierPath *path = [[UIBezierPath alloc] init];
    NSInteger index = 0;
    for (NSDictionary *corner in corners)
    {
        CFDictionaryRef pointDic = (__bridge CFDictionaryRef)corner;
        CGPoint point = CGPointZero;
        CGPointMakeWithDictionaryRepresentation(pointDic, &point);
        
        if (index == 0) {// 第一个点
            [path moveToPoint:point];
        }else {
            [path addLineToPoint:point];
        }
        index += 1;
    }
    
    [path closePath];
    
    // 3. 给图形图层的路径赋值, 代表图层展示怎样的形状
    shapLayer.path = path.CGPath;
    
    // 4. 直接添加图形图层到需要展示的图层
    [self.layer addSublayer:shapLayer];
}

- (void)removeFrameLayer
{
    if (self.layer.sublayers == nil) return;
    //    NSArray *subLayers = self.layer.sublayers;//这样是错误的，不能一边遍历数组，一边删除数组中的元素，一定要生成一个副本来遍历
    NSArray *subLayers = [NSArray arrayWithArray:self.layer.sublayers];
    [subLayers enumerateObjectsUsingBlock:^(id  _Nonnull subLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([subLayer isKindOfClass:[CAShapeLayer class]]) {
            [subLayer removeFromSuperlayer];
        }
    }];
}

@end
