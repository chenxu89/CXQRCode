//
//  ScanQRCodeVC.m
//  二维码
//
//  Created by chenxu on 16/9/5.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "ScanQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQRCodeVC ()<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toBottom;
@property (weak, nonatomic) IBOutlet UIView *scanBackView;
@property (weak, nonatomic) IBOutlet UIImageView *chongjiboImageView;

@property (nonatomic, weak) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic, strong) AVCaptureSession *session;
@end

@implementation ScanQRCodeVC

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self startScanAnimation];
}
- (void)startScan{
    // 1. 设置输入
    // 1.1 获取摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 1.2 把摄像头设备当做输入设备
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    // 2. 设置输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 2.1 设置结果处理的代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 3. 创建会话，连接输入和输出
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    if ([session canAddInput:input] && [session canAddOutput:output]) {
        [session addInput:input];
        [session addOutput:output];
    }else{
        return;
    }
    // 3.1 设置二维码可以识别的码制
    // 设置输出的元数据的类型，必须要在输出添加到会话之后，否则会崩溃
    // output.availableMetadataObjectTypes 或者 AVMetadataObjectTypeQRCode
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // 设置扫描 的兴趣区域
    // metadataoutputs坐标系 CGRectMake(0, 0, 1, 1)  取值范围：0.0 - 1.0
    // metadataoutputs坐标系 以右上角为0 0 类似于横屏，x和y互换，宽高互换
    // 需要把previewlayer坐标系中的rect转为metadataoutputs坐标系中的rect ，下面有两种方法
    // 法一：自己计算
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat x = self.scanBackView.frame.origin.x / bounds.size.width;
    CGFloat y = self.scanBackView.frame.origin.y / bounds.size.height;
    CGFloat width = self.scanBackView.frame.size.width / bounds.size.width;
    CGFloat height = self.scanBackView.frame.size.height / bounds.size.height;
    output.rectOfInterest = CGRectMake(y, x, height, width);
    // 3.2添加视频预览图层(让用户可以看到界面）
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.frame = self.view.layer.bounds;
    self.layer = layer;
//    [self.view.layer addSublayer:layer];
    [self.view.layer insertSublayer:layer atIndex:0];
    // 4. 启动会话（让输入对象开始采集数据，输出对象开始处理数据）
    [session startRunning];
    
    // 法二：用AVCaptureVideoPreviewLayer的方法，且必须要放在[session startRunning];方法之后才有效
//    output.rectOfInterest = [layer metadataOutputRectOfInterestForRect:self.scanBackView.frame];
    
}

- (void)startScanAnimation{
    self.toBottom.constant = self.scanBackView.frame.size.height;
    [self.view layoutIfNeeded];
    self.toBottom.constant = 0;

    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //    [self removeScanAnimation];
    [self startScan];
}
- (void)removeScanAnimation{
    [self.chongjiboImageView.layer removeAllAnimations];
    self.chongjiboImageView.hidden = YES;
}
#pragma mark --- AVCaptureMetadataOutputObjectsDelegate ---
// 扫描到结果之后调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
//    NSLog(@"test");
//    NSLog(@"%@", metadataObjects);
    if (metadataObjects == nil || [metadataObjects count] <= 0) return;
    
    [self removeFrameLayer];
    
    for (NSObject *obj in metadataObjects) {
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            // 转换成为, 二维码, 在预览图层上的真正坐标
            // qrCodeObj.corners 代表二维码的四个角, 需要借助视频预览图层转换成为我们需要的可以用的坐标
            AVMetadataObject *resultObj = [self.layer transformedMetadataObjectForMetadataObject:(AVMetadataObject *)obj];
            AVMetadataMachineReadableCodeObject *qrCodeObj = (AVMetadataMachineReadableCodeObject *)resultObj;
//            NSLog(@"%@", qrCodeObj.stringValue);
//            NSLog(@"%@", qrCodeObj.corners);
            [self drawFrame:qrCodeObj];
        }
    }
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
